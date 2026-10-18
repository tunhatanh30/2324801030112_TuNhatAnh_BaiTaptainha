using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Threading.Tasks;

namespace PricingService.Domain;

public class Tariff
{
    public string Code { get; }
    public BasePremiumRules BasePremiumRules { get; } = new();
    public DiscountMarkupRules DiscountMarkupRules { get; } = new();

    public Tariff(string code) => Code = code;

    public CalculationResult CalculatePrice(Calculation calculation)
    {
        var result = new CalculationResult();

        // Tính base premium cho mỗi cover được chọn (lấy rule đầu tiên khớp coverCode và điều kiện)
        foreach (var coverCode in calculation.SelectedCovers)
        {
            var rule = BasePremiumRules.Find(coverCode, calculation.Subject);
            decimal price = rule == null
                ? 0m
                : ExpressionEvaluator.EvaluateNumber(rule.Formula, calculation.Subject);

            result.Covers[coverCode] = new CoverPrice { Price = price };
            result.TotalPremium += price;
        }

        // Áp dụng các quy đạo giảm/tăng phần trăm
        foreach (var markup in DiscountMarkupRules.All)
        {
            if (ExpressionEvaluator.EvaluateBoolean(markup.Condition, calculation.Subject))
            {
                result.TotalPremium = result.TotalPremium * (1m + markup.Percent / 100m);
            }
        }

        return result;
    }
}

public class Calculation
{
    public string Code { get; }
    public DateTimeOffset PolicyFrom { get; }
    public DateTimeOffset PolicyTo { get; }
    public List<string> SelectedCovers { get; }
    public Dictionary<string, object> Subject { get; }

    public Calculation(string code, DateTimeOffset policyFrom, DateTimeOffset policyTo,
        List<string> selectedCovers, Dictionary<string, object> subject)
    {
        Code = code;
        PolicyFrom = policyFrom;
        PolicyTo = policyTo;
        SelectedCovers = selectedCovers;
        Subject = subject;
    }
}

public class CalculationResult
{
    public decimal TotalPremium { get; set; }
    public Dictionary<string, CoverPrice> Covers { get; set; } = new();
}

public class CoverPrice
{
    public decimal Price { get; set; }
}

public class BasePremiumRule
{
    public string CoverCode { get; set; }
    public string Condition { get; set; }
    public string Formula { get; set; }
}

public class BasePremiumRules
{
    private readonly List<BasePremiumRule> _rules = new();

    public void AddBasePriceRule(string coverCode, string condition, string formula)
        => _rules.Add(new BasePremiumRule { CoverCode = coverCode, Condition = condition, Formula = formula });

    public BasePremiumRule Find(string coverCode, Dictionary<string, object> subject)
    {
        foreach (var rule in _rules)
        {
            if (!string.Equals(rule.CoverCode, coverCode, StringComparison.OrdinalIgnoreCase))
                continue;
            if (rule.Condition == null || ExpressionEvaluator.EvaluateBoolean(rule.Condition, subject))
                return rule;
        }
        return null;
    }
}

public class DiscountMarkupRule
{
    public string Condition { get; set; }
    public decimal Percent { get; set; }
}

public class DiscountMarkupRules
{
    private readonly List<DiscountMarkupRule> _rules = new();

    public void AddPercentMarkup(string condition, decimal percent)
        => _rules.Add(new DiscountMarkupRule { Condition = condition, Percent = percent });

    public IReadOnlyList<DiscountMarkupRule> All => _rules.AsReadOnly();
}

public interface IDataStore
{
    IDictionary<string, Task<Tariff>> Tariffs { get; }
}

public class InMemoryDataStore : IDataStore
{
    public IDictionary<string, Task<Tariff>> Tariffs { get; } = new Dictionary<string, Task<Tariff>>
    {
        ["TRI"] = Task.FromResult(BuildTravel()),
        ["HSI"] = Task.FromResult(BuildHouse()),
        ["FAI"] = Task.FromResult(BuildFarm()),
        ["CAR"] = Task.FromResult(BuildCar()),
    };

    private static Tariff BuildTravel()
    {
        var travel = new Tariff("TRI");
        travel.BasePremiumRules.AddBasePriceRule("C1", null,
            "(NUM_OF_ADULTS) * (DESTINATION == \"EUR\" ? 26.00M : 34.00M)");
        travel.BasePremiumRules.AddBasePriceRule("C2", null, "(NUM_OF_ADULTS + NUM_OF_CHILDREN) * 26.00M");
        travel.BasePremiumRules.AddBasePriceRule("C3", null, "(NUM_OF_ADULTS + NUM_OF_CHILDREN) * 10.00M");
        travel.DiscountMarkupRules.AddPercentMarkup("DESTINATION == \"WORLD\"", 1.5M);
        return travel;
    }

    private static Tariff BuildHouse()
    {
        var house = new Tariff("HSI");
        house.BasePremiumRules.AddBasePriceRule("C1", "TYP == \"APT\"", "AREA * 1.25M");
        house.BasePremiumRules.AddBasePriceRule("C1", "TYP == \"HOUSE\"", "AREA * 1.50M");
        house.BasePremiumRules.AddBasePriceRule("C2", "TYP == \"APT\"", "AREA * 0.25M");
        house.BasePremiumRules.AddBasePriceRule("C2", "TYP == \"HOUSE\"", "AREA * 0.45M");
        house.BasePremiumRules.AddBasePriceRule("C3", null, "30M");
        house.BasePremiumRules.AddBasePriceRule("C4", null, "50M");
        house.DiscountMarkupRules.AddPercentMarkup("FLOOD == \"YES\"", 1.50M);
        house.DiscountMarkupRules.AddPercentMarkup("NUM_OF_CLAIM > 1 ", 1.25M);
        return house;
    }

    private static Tariff BuildFarm()
    {
        var farm = new Tariff("FAI");
        farm.BasePremiumRules.AddBasePriceRule("C1", null, "10M");
        farm.BasePremiumRules.AddBasePriceRule("C2", null, "20M");
        farm.BasePremiumRules.AddBasePriceRule("C3", null, "30M");
        farm.BasePremiumRules.AddBasePriceRule("C4", null, "40M");
        farm.DiscountMarkupRules.AddPercentMarkup("FLOOD == \"YES\"", 1.50M);
        farm.DiscountMarkupRules.AddPercentMarkup("NUM_OF_CLAIM > 2", 2.00M);
        return farm;
    }

    private static Tariff BuildCar()
    {
        var car = new Tariff("CAR");
        car.BasePremiumRules.AddBasePriceRule("C1", null, "100M");
        car.DiscountMarkupRules.AddPercentMarkup("NUM_OF_CLAIM > 2", 1.50M);
        return car;
    }
}

public class ExpressionEvaluator
{
    private enum TokenType
    {
        Number, String, Identifier,
        LParen, RParen, Question, Colon,
        Plus, Minus, Star, Slash,
        EqEq, NotEq, GtEq, LtEq, Gt, Lt,
        AmpAmp, PipePipe, Bang,
        Eof
    }

    private sealed class Token
    {
        public TokenType Type;
        public string Text;
        public decimal Number;
    }

    private enum ValueKind { Number, String }
    private sealed class Value
    {
        public ValueKind Kind;
        public decimal Number;
        public string Text;
    }

    private readonly List<Token> _tokens;
    private readonly Dictionary<string, object> _subject;
    private int _pos;

    private ExpressionEvaluator(string expr, Dictionary<string, object> subject)
    {
        _tokens = Tokenize(expr);
        _subject = subject;
        _pos = 0;
    }

    public static decimal EvaluateNumber(string expr, Dictionary<string, object> subject)
    {
        var v = new ExpressionEvaluator(expr, subject).ParseExpression();
        if (v.Kind != ValueKind.Number)
            throw new InvalidOperationException("Expression did not evaluate to a number.");
        return v.Number;
    }

    public static bool EvaluateBoolean(string expr, Dictionary<string, object> subject)
        => ToBoolean(new ExpressionEvaluator(expr, subject).ParseExpression());

    private Value ParseExpression() => ParseTernary();

    private Value ParseTernary()
    {
        var condition = ParseLogicalOr();
        if (Match(TokenType.Question))
        {
            var trueBranch = ParseExpression();
            Expect(TokenType.Colon);
            var falseBranch = ParseExpression();
            return ToBoolean(condition) ? trueBranch : falseBranch;
        }
        return condition;
    }

    private Value ParseLogicalOr()
    {
        var left = ParseLogicalAnd();
        while (Match(TokenType.PipePipe))
            left = Combine(left, ParseLogicalAnd(), "||");
        return left;
    }

    private Value ParseLogicalAnd()
    {
        var left = ParseEquality();
        while (Match(TokenType.AmpAmp))
            left = Combine(left, ParseEquality(), "&&");
        return left;
    }

    private Value ParseEquality()
    {
        var left = ParseComparison();
        while (true)
        {
            if (Match(TokenType.EqEq)) left = Compare(left, ParseComparison(), "==");
            else if (Match(TokenType.NotEq)) left = Compare(left, ParseComparison(), "!=");
            else break;
        }
        return left;
    }

    private Value ParseComparison()
    {
        var left = ParseAdditive();
        while (true)
        {
            if (Match(TokenType.GtEq)) left = Compare(left, ParseAdditive(), ">=");
            else if (Match(TokenType.LtEq)) left = Compare(left, ParseAdditive(), "<=");
            else if (Match(TokenType.Gt)) left = Compare(left, ParseAdditive(), ">");
            else if (Match(TokenType.Lt)) left = Compare(left, ParseAdditive(), "<");
            else break;
        }
        return left;
    }

    private Value ParseAdditive()
    {
        var left = ParseMultiplicative();
        while (Match(TokenType.Plus)) left = Arithmetic(left, ParseMultiplicative(), "+");
        while (Match(TokenType.Minus)) left = Arithmetic(left, ParseMultiplicative(), "-");
        return left;
    }

    private Value ParseMultiplicative()
    {
        var left = ParseUnary();
        while (Match(TokenType.Star)) left = Arithmetic(left, ParseUnary(), "*");
        while (Match(TokenType.Slash)) left = Arithmetic(left, ParseUnary(), "/");
        return left;
    }

    private Value ParseUnary()
    {
        if (Match(TokenType.Minus)) return Negate(ParseUnary());
        if (Match(TokenType.Bang)) return Not(ParseUnary());
        return ParsePrimary();
    }

    private Value ParsePrimary()
    {
        var tok = Peek();
        switch (tok.Type)
        {
            case TokenType.Number:
                Advance();
                return new Value { Kind = ValueKind.Number, Number = tok.Number };
            case TokenType.String:
                Advance();
                return new Value { Kind = ValueKind.String, Text = tok.Text };
            case TokenType.LParen:
                Advance();
                var v = ParseExpression();
                Expect(TokenType.RParen);
                return v;
            case TokenType.Identifier:
                Advance();
                if (_subject.TryGetValue(tok.Text, out var raw))
                {
                    if (raw is decimal d) return new Value { Kind = ValueKind.Number, Number = d };
                    if (raw is double dd) return new Value { Kind = ValueKind.Number, Number = (decimal)dd };
                    if (raw is int ii) return new Value { Kind = ValueKind.Number, Number = ii };
                    if (raw is string s) return new Value { Kind = ValueKind.String, Text = s };
                    return new Value { Kind = ValueKind.Number,
                        Number = Convert.ToDecimal(raw, CultureInfo.InvariantCulture) };
                }
                return new Value { Kind = ValueKind.Number, Number = 0m };
            default:
                throw new InvalidOperationException($"Unexpected token {Peek().Type}");
        }
    }

    private static Value Arithmetic(Value a, Value b, string op)
    {
        var x = ToNumber(a);
        var y = ToNumber(b);
        return op switch
        {
            "+" => Num(x + y),
            "-" => Num(x - y),
            "*" => Num(x * y),
            "/" => Num(x / y),
            _ => throw new InvalidOperationException($"Unknown operator {op}")
        };
    }

    private static Value Compare(Value a, Value b, string op)
    {
        bool result;
        if (a.Kind == ValueKind.String || b.Kind == ValueKind.String)
        {
            var sa = a.Kind == ValueKind.String ? a.Text : a.Number.ToString(CultureInfo.InvariantCulture);
            var sb = b.Kind == ValueKind.String ? b.Text : b.Number.ToString(CultureInfo.InvariantCulture);
            result = op switch
            {
                "==" => sa == sb,
                "!=" => sa != sb,
                _ => throw new InvalidOperationException($"Operator {op} not supported for strings")
            };
        }
        else
        {
            var x = a.Number;
            var y = b.Number;
            result = op switch
            {
                "==" => x == y,
                "!=" => x != y,
                ">" => x > y,
                "<" => x < y,
                ">=" => x >= y,
                "<=" => x <= y,
                _ => throw new InvalidOperationException($"Unknown operator {op}")
            };
        }
        return new Value { Kind = ValueKind.Number, Number = result ? 1m : 0m };
    }

    private static Value Combine(Value a, Value b, string op)
    {
        var result = op == "||" ? ToBoolean(a) || ToBoolean(b) : ToBoolean(a) && ToBoolean(b);
        return new Value { Kind = ValueKind.Number, Number = result ? 1m : 0m };
    }

    private static Value Negate(Value v) => Num(-ToNumber(v));
    private static Value Not(Value v) => Num(ToBoolean(v) ? 0m : 1m);
    private static decimal ToNumber(Value v)
        => v.Kind == ValueKind.Number ? v.Number : decimal.Parse(v.Text, CultureInfo.InvariantCulture);
    private static bool ToBoolean(Value v)
        => v.Kind == ValueKind.Number ? v.Number != 0m : !string.IsNullOrEmpty(v.Text);
    private static Value Num(decimal n) => new Value { Kind = ValueKind.Number, Number = n };

    private Token Peek() => _tokens[_pos];
    private bool Match(TokenType type)
    {
        if (Peek().Type == type) { _pos++; return true; }
        return false;
    }
    private void Advance() => _pos++;
    private void Expect(TokenType type)
    {
        if (Peek().Type != type)
            throw new InvalidOperationException($"Expected {type}, got {Peek().Type}");
        Advance();
    }

    private static List<Token> Tokenize(string expr)
    {
        var tokens = new List<Token>();
        int i = 0, n = expr.Length;
        while (i < n)
        {
            char c = expr[i];
            if (char.IsWhiteSpace(c)) { i++; continue; }

            if (c == '"')
            {
                i++;
                var sb = new StringBuilder();
                while (i < n && expr[i] != '"')
                {
                    if (expr[i] == '\\' && i + 1 < n) { sb.Append(expr[++i]); i++; continue; }
                    sb.Append(expr[i++]);
                }
                if (i < n) i++;
                tokens.Add(new Token { Type = TokenType.String, Text = sb.ToString() });
                continue;
            }

            if (char.IsDigit(c) || c == '.')
            {
                var sb = new StringBuilder();
                while (i < n && (char.IsDigit(expr[i]) || expr[i] == '.')) sb.Append(expr[i++]);
                if (i < n && expr[i] == 'M') i++; // bỏ tố tiền tố decimal của C#
                tokens.Add(new Token
                {
                    Type = TokenType.Number,
                    Text = sb.ToString(),
                    Number = decimal.Parse(sb.ToString(), CultureInfo.InvariantCulture)
                });
                continue;
            }

            if (char.IsLetter(c) || c == '_')
            {
                var sb = new StringBuilder();
                while (i < n && (char.IsLetterOrDigit(expr[i]) || expr[i] == '_')) sb.Append(expr[i++]);
                tokens.Add(new Token { Type = TokenType.Identifier, Text = sb.ToString() });
                continue;
            }

            if (i + 1 < n)
            {
                var two = expr.Substring(i, 2);
                if (two == "==" || two == "!=" || two == ">=" || two == "<=" || two == "&&" || two == "||")
                {
                    tokens.Add(new Token
                    {
                        Type = two switch
                        {
                            "==" => TokenType.EqEq,
                            "!=" => TokenType.NotEq,
                            ">=" => TokenType.GtEq,
                            "<=" => TokenType.LtEq,
                            "&&" => TokenType.AmpAmp,
                            _ => TokenType.PipePipe
                        },
                        Text = two
                    });
                    i += 2;
                    continue;
                }
            }

            switch (c)
            {
                case '(': tokens.Add(new Token { Type = TokenType.LParen }); i++; break;
                case ')': tokens.Add(new Token { Type = TokenType.RParen }); i++; break;
                case '?': tokens.Add(new Token { Type = TokenType.Question }); i++; break;
                case ':': tokens.Add(new Token { Type = TokenType.Colon }); i++; break;
                case '+': tokens.Add(new Token { Type = TokenType.Plus }); i++; break;
                case '-': tokens.Add(new Token { Type = TokenType.Minus }); i++; break;
                case '*': tokens.Add(new Token { Type = TokenType.Star }); i++; break;
                case '/': tokens.Add(new Token { Type = TokenType.Slash }); i++; break;
                case '>': tokens.Add(new Token { Type = TokenType.Gt }); i++; break;
                case '<': tokens.Add(new Token { Type = TokenType.Lt }); i++; break;
                case '!': tokens.Add(new Token { Type = TokenType.Bang }); i++; break;
                default: throw new InvalidOperationException($"Unexpected character '{c}'");
            }
        }
        tokens.Add(new Token { Type = TokenType.Eof });
        return tokens;
    }
}
