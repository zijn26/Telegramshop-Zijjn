from .strings import TRANSLATIONS as BASE_TRANSLATIONS
from .vi_part1 import VI_TRANSLATIONS_PART1
from .vi_part2 import VI_TRANSLATIONS_PART2
from .vi_part3 import VI_TRANSLATIONS_PART3


DEFAULT_LOCALE = "vi"

VI_TRANSLATIONS = {
    **VI_TRANSLATIONS_PART1,
    **VI_TRANSLATIONS_PART2,
    **VI_TRANSLATIONS_PART3,
}

LANGUAGE_MESSAGES = {
    "vi": {
        "btn.language": "🌐 Ngôn ngữ",
        "language.choose": "🌐 Chọn ngôn ngữ giao diện:",
        "language.changed": "✅ Đã đổi ngôn ngữ sang Tiếng Việt",
        "language.invalid": "❌ Ngôn ngữ không hợp lệ",
    },
    "en": {
        "btn.language": "🌐 Language",
        "language.choose": "🌐 Choose the interface language:",
        "language.changed": "✅ Language changed to English",
        "language.invalid": "❌ Invalid language",
    },
    "ru": {
        "btn.language": "🌐 Язык",
        "language.choose": "🌐 Выберите язык интерфейса:",
        "language.changed": "✅ Язык изменён на русский",
        "language.invalid": "❌ Недопустимый язык",
    },
}

TRANSLATIONS = {
    "vi": {**VI_TRANSLATIONS, **LANGUAGE_MESSAGES["vi"]},
    "en": {**BASE_TRANSLATIONS["en"], **LANGUAGE_MESSAGES["en"]},
    "ru": {**BASE_TRANSLATIONS["ru"], **LANGUAGE_MESSAGES["ru"]},
}
