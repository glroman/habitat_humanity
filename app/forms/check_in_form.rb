class CheckInForm
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :name, :email, :work_site_id, :signature

  validates :name,      presence: true
  validates :email,     presence: true
  validates :work_site, presence: true
  validates :signature, presence: true

  def initialize(attributes={})
    @name         = attributes[:name]
    @email        = attributes[:email]
    @work_site_id = attributes[:work_site_id]
    @signature    = attributes[:signature]
  end

  def model_name
    ActiveModel::Name.new(self.class, nil, self.class.name)
  end

  def persisted?
    false
  end

  def save
    volunteer.save!
    shift.save!
    shift_event.save!
  end

  def work_site
    return nil if work_site_id.nil?

    @work_site ||= WorkSite.find work_site_id
  end

  private

  def shift
    @shift ||= Shift.find_by(
      volunteer_id: volunteer,
      work_site_id: work_site,
      day:          Date.today
    ) || Shift.new(
      volunteer: volunteer,
      work_site: work_site,
      day:       Date.today
    )
  end

  def shift_event
    @shift_event ||= shift.shift_events.build(
      occurred_at: Time.current,
      signature:   signature,
      action:      'start_shift'
    )
  end

  def volunteer
    @volunteer ||= Volunteer.find_by(email: email) ||
      Volunteer.new(name: name, email: email)
  end
end