using System.Security.Claims;
using System.Security.Principal;
using ChatService.Api.Commands;
using Xunit;

namespace ChatService.Test;

public class ChatServiceTests
{
    [Fact]
    public void SendNotificationCommand_CanSetAndGetMessage()
    {
        var command = new SendNotificationCommand { Message = "Hello world" };
        Assert.Equal("Hello world", command.Message);
    }

    [Fact]
    public void NameUserIdProvider_InstantiatesCorrectly()
    {
        var provider = new NameUserIdProvider();
        Assert.NotNull(provider);
    }
}
