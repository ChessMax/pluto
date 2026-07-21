const String courseTemplateAsset = '''
---
id: @model.id
# title max 64 chars
title: @model.title
title_en: @model.titleEn
@(model.configBlock ?? '')---
''';
