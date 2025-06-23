package service

import (
	"testing"
)

// 8157751774:AAEn4_YXSBTNfFVvx2ajI3q2-z6gOQkVuRI
var tokens = "8107927288:AAFROeRuOh6YS7Avr1Q0orPYJEAwHvhqP0Y"
var chatId = "-7283274026"
var content = "HTML示例：<code>1234</code>\nMarkdown示例：*1234*"
var messageType = "html"

func TestName(t *testing.T) {
	var telegramBotService = TelegramBotService{}
	message, err := telegramBotService.SendTgMessage(tokens, chatId, content, messageType)
	if err != nil {
		t.Error(err)
		return
	}
	t.Log(message)
}
