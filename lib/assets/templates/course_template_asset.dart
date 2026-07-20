const String courseTemplateAsset = '''
---
id: @model.id
# title max 64 chars
title: @model.title
title_en: @model.titleEn
@(model.configBlock ?? '')---

<!-- Краткое описание (от 100 до 512 символов) -->
```summary
@(model.summary ?? '')```

<!-- Чему вы научитесь -->
<!-- Каждый пункт начинайте с новой строки -->
```acquired_assets
@(model.acquiredAssets ?? '')```

<!-- О курсе -->
```description
@(model.description ?? '')```

<!-- Для кого этот курс -->
```target_audience
@(model.targetAudience ?? '')```

<!-- Начальные требования -->
```requirements
@(model.requirements ?? '')```

<!-- Как проходит обучение -->
```learning_format
@(model.learningFormat ?? '')```

<!-- Что вы получаете -->
```acquired_skills
@(model.acquiredSkills ?? '')```
''';
