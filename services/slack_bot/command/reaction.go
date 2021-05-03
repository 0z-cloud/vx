package command

import (
	"github.com/innogames/slack-bot/bot"
	"github.com/innogames/slack-bot/bot/matcher"
	"github.com/innogames/slack-bot/bot/msg"
	"github.com/innogames/slack-bot/bot/util"
)

// NewReactionCommand simply adds a reaction to the current message...used in "commands" and other internal commands
func NewReactionCommand(base bot.BaseCommand) bot.Command {
	return &reactionCommand{base}
}

type reactionCommand struct {
	bot.BaseCommand
}

func (c *reactionCommand) GetMatcher() matcher.Matcher {
	return matcher.NewGroupMatcher(
		matcher.NewRegexpMatcher(`add reaction :(?P<reaction>.*):`, c.Add),
		matcher.NewRegexpMatcher(`remove reaction :(?P<reaction>.*):`, c.Remove),
	)
}

func (c *reactionCommand) Add(match matcher.Result, message msg.Message) {
	reaction := match.GetString("reaction")
	c.AddReaction(util.Reaction(reaction), message)
}

func (c *reactionCommand) Remove(match matcher.Result, message msg.Message) {
	reaction := match.GetString("reaction")
	c.RemoveReaction(util.Reaction(reaction), message)
}

func (c *reactionCommand) GetHelp() []bot.Help {
	return []bot.Help{
		{
			Command:     "add reaction",
			Description: "add a reaction on a message",
			Examples: []string{
				"add reaction :white_check_mark:",
			},
		},
		{
			Command:     "remove reaction",
			Description: "remove a reaction on a message",
			Examples: []string{
				"remove reaction :white_check_mark:",
			},
		},
	}
}
