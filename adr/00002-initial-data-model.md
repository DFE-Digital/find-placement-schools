# ADR-002: Initial data model

Date: 2025-07-18

## Status

Accepted

---

## Context

This service will track school placement preferences for Initial Teacher Training (ITT). The intent is to allow schools to express their willingness and ability to host placements for trainee teachers, which we hope will facilitate more placements in the market.

To enable us to do this, we need to define a data model that captures:

- Relationships between users, schools, and ITT providers
- The school interest in hosting placements for each academic year
- Organisation details such as URN, UKPRN, addresses and contact information
- Subjects that placements can be categorised by

### Key domain concepts:

- **Users** (teachers, provider staff, school staff, DfE staff)
- **Organisations** (schools and training providers)
- **Placement Preferences** (set up by schools, expresses the willingness/ability to host placements)
- **Academic Years** (placement context)
- **Subjects** (categorisation for placements)

---

## Decision

We will create a data model using a relational database schema. Our initial model will include the following tables and relationships:

```mermaid
erDiagram

  %% === Core time period model ===
  AcademicYear {
    uuid id PK "Primary key"
    string name "E.g. 2024–2025"
    date starts_on "Term start date"
    date ends_on "Term end date"
  }

  %% === User model and identity ===
  User {
    uuid id PK "Primary key"
    boolean admin "System admin toggle"
    string first_name "User’s first name"
    string last_name "User’s last name"
    string email_address "Used for sign-in and notifications"
    uuid dfe_sign_in_uid "External identity ID"
    datetime last_signed_in_at "Timestamp of last sign-in"
    uuid organisation_id FK "Legacy or default organisation"
    uuid current_organisation_id FK "Currently selected org"
  }

  %% === User to organisation association ===
  UserOrganisation {
    uuid id PK "Primary key"
    uuid organisation_id FK "Organisation the user is linked to"
    uuid user_id FK "User in the relationship"
  }

  %% Supports many-to-many relationship between users and organisations (e.g. MATs, school groups)

  %% === Organisation model ===
  Organisation {
    uuid id PK "Primary key"
    string name "School or provider name"
    string urn "Unique Reference Number"
    string ukprn "UK Provider Reference Number"
    string code "GIAS code"
    float longitude "Geo location (lon)"
    float latitude "Geo location (lat)"
    string email_address "Generic contact email"
    boolean school "Is a school"
    boolean provider "Is an ITT provider"
  }

  %% === Organisation metadata ===
  OrganisationDetail {
    uuid id PK
    uuid organisation_id FK "Linked organisation"
    string gias_stuff "Additional metadata from GIAS"
  }

  %% Holds additional metadata (e.g. GIAS data), keeping Organisation table lean

  OrganisationContact {
    uuid id PK
    string first_name "Contact’s first name"
    string last_name "Contact’s last name"
    string email_address "Contact’s email"
    string phone "Contact telephone number"
    string role "E.g. ‘Placement lead’"
    uuid organisation_id FK "Linked organisation"
  }
  %% For listing individual contacts at a school or provider — e.g. placement coordinators

  OrganisationAddress {
    uuid id PK
    string address_1 "Field for information about the address"
    string address_2 "Field for information about the address"
    string address_3 "Field for information about the address"
    string town "Town"
    string city "City"
    string county "County"
    string postcode "Postcode"
    uuid organisation_id FK "Linked organisation"
  }
  %% Postal addresses are modeled separately to allow normalisation and optional geocoding

  %% === School placement availability ===
  PlacementPreference {
    uuid id PK "Primary key"
    enum appetite "e.g. not_interested, interested, unsure"
    uuid organisation_id FK "Which school"
    uuid academic_year_id FK "Which academic year"
    uuid created_by FK "User who created it"
    jsonb placement_details "Structured JSON field for quantity of placements, additional notes. Should be strucured more definitively in the future."
  }
  %% A school’s declaration of whether and how they’re offering placements in a given academic year
  %% Appetite might be: "not_interested", "interested", or "unsure". Names to be defined in the future.
  %% `placement_details` is stored in JSONB to allow flexible structured fields

  %% === Subject taxonomy ===
  PlacementSubject {
    uuid id PK
    string name "E.g. Biology"
    string code "Unique code"
    enum phase "Primary, Secondary"
    uuid parent_subject_id FK "If part of a broader subject group e.g French is part of Modern foreign languages."
  }
  %% Accredited subjects are categorised by phase (e.g. "primary", "secondary") and support nesting

  %% === Relationships with comments ===
  OrganisationDetail |o--|| Organisation : "Each detail row belongs to one organisation"
  OrganisationAddress |o--|| Organisation : "Each address belongs to one organisation"
  OrganisationContact |o--|| Organisation : "Each contact belongs to one organisation"
  UserOrganisation }o--|| Organisation : "An organisation has many user links"
  UserOrganisation }o--|| User : "A user can belong to many organisations"
  PlacementPreference }o--|| Organisation : "Placement preference belongs to a school"
  PlacementPreference }o--|| AcademicYear : "Scoped to a specific academic year"
  PlacementPreference }o--|| User : "Created by a user"
```

#### User

Represents a real person who can log into and interact with the service.

- Fields: `first_name`, `last_name`, `email_address`, `admin`, `dfe_sign_in_uid`, `last_signed_in_at`
- Linked to organisations via `UserOrganisation`, users may belong to multiple organisations.
- Sign in flow will be handled via DfE Sign-in API, using `dfe_sign_in_uid`
- The `admin` boolean allows for internal DfE users to be distinguished from regular users.


#### Organisation

Represents either a school or a provider via the type column, this uses Single Table Inheritance (STI).

- Fields: `urn`, `ukprn`, `code`, `longitude`, `latitude`, `email_address`, `type`, `admissions_policy`, `district_admin_code`, `district_admin_name`, `gender`, `group`, `last_inspection_date`, `local_authority_code`, `local_authority_name`, `maximum_age`, `minimum_age`, `percentage_free_school_meals`, `phase`, `rating`, `rating`, `religious_character`, `school_capacity`, `send_provision`, `special_classes`, `telephone`, `total_boys`, `total_girls`, `type_of_establishment`, `urban_or_rural` and `website`
- Longitude and latitude are used for distance based searching between schools and a specified location.
- The vast majority of these fields are sourced from Get Information About Schools (GIAS) and are only relevant for school records.

#### UserMembership

Join table that links `User` and `Organisation` to represent the many-to-many relationship between users and organisations.

- Fields: `organisation_id`, `user_id`

#### AcademicYear

Used to set the placement preferences for each year. Schools utilise academic years to define the start and end of the school year, we have chosen to use this as the basis for our placement preferences.

- Fields: `name`, `starts_on`, `ends_on`

#### PlacementPreference

Records whether and how a school is offering placements.

- Fields: `academic_year_id`, `organisation_id`, `created_by_id`, `appetite`, `placement_details`
- Has foreign keys for `organisation`, `academic_year`, and `user`
- Use of a JSONB field allows flexibility in defining the placement preferences. This is useful in the initial setup, but replacing this with a more structured model should be investigated in the future. 

#### PlacementSubject

Stores the subjects that accredited ITT providers can offer placements in.

- Fields: `name`, `code`, `phase`, `parent_subject_id`
- Phase can be either "primary" or "secondary"

#### OrganisationAddress 

Stores the postal address of an organisation, allowing for multiple addresses per organisation.

- Fields: `address_1`, `address_2`, `address_3`, `town`, `city`, `county`, `postcode`


#### OrganisationContact

Stores contact details for individuals at an organisation, such as placement coordinators.

- Fields: `organisation_id`, `first_name`, `last_name`, `email_address`

---

## Considerations

- Usage of a JSONB field in `PlacementPreference` allows for flexible data storage, but may complicate querying and validation.
- This ERB will need to be refined as we gather more requirements and feedback from users, this isn't a final data model.

---

## Next Steps

- Create migrations to instantiate the tables defined in the entity relationship diagram

---
