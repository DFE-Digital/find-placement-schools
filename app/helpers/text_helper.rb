module TextHelper
  def embedded_link_text(translations)
    sanitize translations, tags: %w[a], attributes: %w[href target class]
  end

  def value_or_unknown(
    value: nil,
    empty_text: I18n.t("helpers.text_helper.unknown")
  )
    return { text: value } if value.present?

    { text: empty_text, classes: "govuk-hint" }
  end
end
