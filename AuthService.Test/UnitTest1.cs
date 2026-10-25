using AuthService.DataAccess;
using AuthService.Domain;
using Microsoft.Extensions.Options;
using Xunit;

namespace AuthService.Test;

public class AuthServiceTests
{
    private readonly Domain.AuthService authService;

    public AuthServiceTests()
    {
        var db = new InsuranceAgentsInMemoryDb();
        var options = Options.Create(new AppSettings
        {
            Secret = "THIS_IS_A_VERY_LONG_SECRET_KEY_FOR_JWT_SIGNING_1234567890"
        });
        authService = new Domain.AuthService(db, options);
    }

    [Fact]
    public void Authenticate_WithValidCredentials_ReturnsAuthResult()
    {
        var result = authService.Authenticate("jimmy.solid", "secret");

        Assert.NotNull(result);
        Assert.Equal("jimmy.solid", result.Login);
        Assert.NotEmpty(result.Token);
        Assert.Equal("SALESMAN", result.UserType);
    }

    [Fact]
    public void Authenticate_WithInvalidPassword_ReturnsNull()
    {
        var result = authService.Authenticate("jimmy.solid", "wrongpassword");

        Assert.Null(result);
    }

    [Fact]
    public void Authenticate_WithNonExistentUser_ReturnsNull()
    {
        var result = authService.Authenticate("unknown.user", "secret");

        Assert.Null(result);
    }

    [Fact]
    public void AgentFromLogin_WithExistingAgent_ReturnsAgent()
    {
        var agent = authService.AgentFromLogin("admin");

        Assert.NotNull(agent);
        Assert.Equal("admin", agent.Login);
    }
}
