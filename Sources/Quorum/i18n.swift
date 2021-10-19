import LGNCore

typealias i18n = LGNCore.i18n
typealias Phrase = i18n.Phrase

func getPhrases() -> [i18n.Locale: i18n.Phrases] {
    [
        .ruRU: [
            "Comment must be less than {Length} characters long": Phrase(
                one: "Комментарий должен быть не короче {Length} символа",
                few: "Комментарий должен быть не короче {Length} символов",
                many: "Комментарий должен быть не короче {Length} символов",
                other: "Комментарий должен быть не короче {Length} символа"
            ),
            "You are forbidden to leave comments here": "Вам нельзя тут комментировать",
            "Too short comment": "Слишком короткий комментарий",
            "Replying comment not found": "Комментарий не найден",
            "Post not found": "Пост не найден",
            "Post is read only": "В пост уже нельзя писать комменты",
            "Comment not found": "Комментарий не найден",
            "You're editing too often": "Вы слишком часто редактируете комментарий",
            "You're commenting too often": "Вы слишком часто пишете комментарии",

            // LGNC messages
            "Internal server error": "Ошибка сервера",
            "Type mismatch": "Неправильный тип",
            "Value missing": "Не заполнено",
            "Invalid value": "Некорректное значение",
            "Value must be at most {Length} characters long": Phrase(
                one: "Значение должно быть не длиннее {Length} символа",
                few: "Значение должно быть не длиннее {Length} символов",
                many: "Значение должно быть не длиннее {Length} символов",
                other: "Значение должно быть не длиннее {Length} символа"
            ),
            "Value must be at least {Length} characters long": Phrase(
                one: "Значение должно быть не короче {Length} символа",
                few: "Значение должно быть не короче {Length} символов",
                many: "Значение должно быть не короче {Length} символов",
                other: "Значение должно быть не короче {Length} символа"
            ),
            "Fields must be identical": "Поля должны быть идентичны",
            "Invalid date format (valid format: {format})": "Неправильный формат даты (правильный формат: {format})",
        ],
        .enUS: [:],
    ]
}
