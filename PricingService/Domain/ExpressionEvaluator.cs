using System;
using System.Collections.Generic;
using System.Globalization;

namespace PricingService.Domain;

internal static class ExpressionEvaluator
{
    public static decimal EvaluateDecimal(string expression, IReadOnlyDictionary<string, object> subject)
    {
        if (string.IsNullOrWhiteSpace(expression))
            return 0M;
        var parser = new Parser(expression, subject);
        return ToDecimal(parser.ParseExpression());
    }

    public static bool EvaluateBool(string expression, IReadOnlyDictionary<string, object> subject)
    {
        if (string.IsNullOrWhiteSpace(expression))
            return true;
        var parser = new Parser(expression, subject);
        return ToBool(parser.ParseExpression());
    }

    private static decimal ToDecimal(object value) => value switch
    {
        decimal d => d,
        double d => (decimal)d,
        int i => i,
        long l => l,
        bool b => b ? 1M : 0M,
        string s => decimal.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out var parsed)
            ? parsed
            : 0M,
        _ => 0M
    };

    private static bool ToBool(object value) => value switch
    {
        bool b => b,
        decimal d => d != 0M,
        double d => d != 0,
        int i => i != 0,
        long l => l != 0,
        string s => !string.IsNullOrEmpty(s),
        _ => false
    };

    private static int CompareNumbers(object a, object b) => ToDecimal(a).CompareTo(ToDecimal(b));

    private static int CompareObjects(object a, object b)
    {
        if (a is string sa && b is string sb)
            return string.Compare(sa, sb, StringComparison.Ordinal);
        return ToDecimal(a).CompareTo(ToDecimal(b));
    }

    private sealed class Parser
    {
        private readonly string _e;
        private readonly IReadOnlyDictionary<string, object> _s;
        private int _p;

        public Parser(string e, IReadOnlyDictionary<string, object> s)
        {
            _e = e;
            _s = s;
        }

        private char Peek() => _p < _e.Length ? _e[_p] : '\0';
        private char Next() => _p < _e.Length ? _e[_p++] : '\0';

        private bool Match(char c)
        {
            if (Peek() == c)
            {
                _p++;
                return true;
            }
            return false;
        }

        private bool Match(string s)
        {
            if (_p + s.Length <= _e.Length && _e.AsSpan(_p, s.Length).SequenceEqual(s))
            {
                _p += s.Length;
                return true;
            }
            return false;
        }

        private void SkipWhitespace()
        {
            while (_p < _e.Length && char.IsWhiteSpace(_e[_p]))
                _p++;
        }

        private void Expect(char c)
        {
            SkipWhitespace();
            if (!Match(c))
                throw new ApplicationException($"Expected character '{c}' while parsing expression.");
        }

        public object ParseExpression() => ParseTernary();

        // ternary := logicalOr ('?' expression ':' expression)?
        private object ParseTernary()
        {
            var condition = ParseLogicalOr();
            SkipWhitespace();
            if (Match('?'))
            {
                var trueBranch = ParseExpression();
                Expect(':');
                var falseBranch = ParseExpression();
                return ToBool(condition) ? trueBranch : falseBranch;
            }
            return condition;
        }

        // logicalOr := logicalAnd ('||' logicalAnd)*
        private object ParseLogicalOr()
        {
            var left = ParseLogicalAnd();
            while (true)
            {
                SkipWhitespace();
                if (Match("||"))
                    left = ToBool(left) || ToBool(ParseLogicalAnd());
                else
                    break;
            }
            return left;
        }

        // logicalAnd := equality ('&&' equality)*
        private object ParseLogicalAnd()
        {
            var left = ParseEquality();
            while (true)
            {
                SkipWhitespace();
                if (Match("&&"))
                    left = ToBool(left) && ToBool(ParseEquality());
                else
                    break;
            }
            return left;
        }

        // equality := comparison (('==' | '!=') comparison)*
        private object ParseEquality()
        {
            var left = ParseComparison();
            while (true)
            {
                SkipWhitespace();
                if (Match("=="))
                    left = CompareObjects(left, ParseComparison()) == 0;
                else if (Match("!="))
                    left = CompareObjects(left, ParseComparison()) != 0;
                else
                    break;
            }
            return left;
        }

        // comparison := addition (('>' | '<' | '>=' | '<=') addition)*
        private object ParseComparison()
        {
            var left = ParseAddition();
            while (true)
            {
                SkipWhitespace();
                bool result;
                if (Match(">="))
                    result = CompareNumbers(left, ParseAddition()) >= 0;
                else if (Match("<="))
                    result = CompareNumbers(left, ParseAddition()) <= 0;
                else if (Match(">"))
                    result = CompareNumbers(left, ParseAddition()) > 0;
                else if (Match("<"))
                    result = CompareNumbers(left, ParseAddition()) < 0;
                else
                    break;
                left = result;
            }
            return left;
        }

        // addition := multiplication (('+' | '-') multiplication)*
        private object ParseAddition()
        {
            var left = ParseMultiplication();
            while (true)
            {
                SkipWhitespace();
                if (Match('+'))
                    left = ToDecimal(left) + ToDecimal(ParseMultiplication());
                else if (Match('-'))
                    left = ToDecimal(left) - ToDecimal(ParseMultiplication());
                else
                    break;
            }
            return left;
        }

        // multiplication := unary (('*' | '/') unary)*
        private object ParseMultiplication()
        {
            var left = ParseUnary();
            while (true)
            {
                SkipWhitespace();
                if (Match('*'))
                    left = ToDecimal(left) * ToDecimal(ParseUnary());
                else if (Match('/'))
                    left = ToDecimal(left) / ToDecimal(ParseUnary());
                else
                    break;
            }
            return left;
        }

        // unary := ('!' | '-') unary | primary
        private object ParseUnary()
        {
            SkipWhitespace();
            if (Match('!'))
                return !ToBool(ParseUnary());
            if (Match('-'))
                return -ToDecimal(ParseUnary());
            return ParsePrimary();
        }

        // primary := NUMBER | STRING | '(' expression ')' | IDENTIFIER
        private object ParsePrimary()
        {
            SkipWhitespace();

            if (Match('('))
            {
                var value = ParseExpression();
                Expect(')');
                return value;
            }

            if (Match('"'))
            {
                int start = _p;
                while (_p < _e.Length && _e[_p] != '"')
                    _p++;
                var text = _e.Substring(start, _p - start);
                if (_p < _e.Length)
                    _p++; // consume closing quote
                return text;
            }

            if (_p < _e.Length && (char.IsDigit(_e[_p]) || _e[_p] == '.'))
                return ParseNumber();

            if (_p < _e.Length && (char.IsLetter(_e[_p]) || _e[_p] == '_'))
                return ParseIdentifier();

            throw new ApplicationException($"Unexpected character '{Peek()}' while parsing expression.");
        }

        private object ParseNumber()
        {
            int start = _p;
            while (_p < _e.Length && (char.IsDigit(_e[_p]) || _e[_p] == '.'))
                _p++;
            int numericEnd = _p;
            if (_p < _e.Length && (_e[_p] == 'M' || _e[_p] == 'm'))
                _p++; // consume the decimal suffix
            return decimal.Parse(_e.Substring(start, numericEnd - start),
                NumberStyles.Any, CultureInfo.InvariantCulture);
        }

        private object ParseIdentifier()
        {
            int start = _p;
            while (_p < _e.Length && (char.IsLetterOrDigit(_e[_p]) || _e[_p] == '_'))
                _p++;
            var name = _e.Substring(start, _p - start);
            return _s.TryGetValue(name, out var value) ? value : 0M;
        }
    }
}
