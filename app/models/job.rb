class Job < ActiveRecord::Base
  belongs_to :job_type
  belongs_to :category
  belongs_to :location
  
  has_many :job_applicants

  named_scope :active, :conditions => {:is_active => true}
  
  validates_presence_of :title
  validates_presence_of :description

  validates_presence_of :company
  validates_presence_of :poster_email
  
  before_save :format_fields
  
  # create a default populated job
  def self.new_default(init_values = nil)
    init_values ||= {}
    Job.new({:job_type => JobType.first, :apply_online => true}.merge(init_values))
  end
  
  def self.recent_jobs
    active.find(:all, :order => "created_at DESC", :limit => 7)
  end
  
  def self.popular_jobs
    active.find(:all, :order => "job_applicants_size DESC", :limit => 7)
  end
  
  # switch label used for html forms
  def location_switch_label
    if outside_location.blank?
      "other"
    else
      "pick one from the list"
    end
  end
  
  # get a string representation of where the job is located
  def located_at
    return @located_at if @located_at
    
    # return outside location if set
    unless self.outside_location.blank?
      @located_at = self.outside_location
      return @located_at
    end
    
    # return location if applicable
    if self.location
      @located_at = self.location.name
      return @located_at
    end
    
    @located_at = "Anywhere"
    return @located_at
  end
  
  protected
  def format_fields
    self.description_html = format_html(self.description)
  end
  
  def format_html(content)
    case self.formatting_type
    when "html"
      content
    when "simple"
      simple_format(content)
    else # Default to Textile
      RedCloth.new(content).to_html(:textile)
    end
  end
  
end
