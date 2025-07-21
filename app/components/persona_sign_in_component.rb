class PersonaSignInComponent < ApplicationComponent
  attr_reader :persona

  PERSONAS = {
    "anne" => {
      persona_type: "SCHOOL",
      description: "Anne is a school user.",
      tag_colour: "purple",
      roles: [
        "Updating information on schools hosting interest"
      ]
    },
    "colin" => {
      persona_type: "SUPPORT",
      description: "Colin is a DfE support agent who has administrator access to all organisations.",
      tag_colour: "blue",
      roles: []
    },
    "mary" => {
      persona_type: "MULTI-ORG",
      description: "Mary is a part-time teacher in a multi academy trust (MAT), but also leads a SCITT.",
      tag_colour: "yellow",
      roles: [
        "Organising placements for trainees"
      ]
    },
    "patricia" => {
      persona_type: "UNIVERSITY",
      description: "Patricia is a placements manager at a higher education institute (HEI).",
      tag_colour: "orange",
      roles: [
        "Organising placements for trainees"
      ]
    }
  }

  def initialize(persona, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @persona = persona
  end

  def persona_data
    @persona_data ||= PERSONAS[persona.first_name.downcase]
  end
end
