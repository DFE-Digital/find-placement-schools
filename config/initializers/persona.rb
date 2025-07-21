PERSONAS = [
  {
    first_name: "Anne",
    last_name: "Wilson",
    email_address: "anne_wilson@example.org"
  },
  {
    first_name: "Mary",
    last_name: "Lawson",
    email_address: "mary@example.com"
  },
  {
    first_name: "Patricia",
    last_name: "Adebayo",
    email_address: "patricia@example.com"
  },
  {
    first_name: "Colin",
    last_name: "Chapman",
    email_address: "colin.chapman@example.com",
    admin: true
  }
].freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email_address] }
