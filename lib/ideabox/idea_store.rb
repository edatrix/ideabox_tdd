class IdeaStore

  def self.save(idea)
    idea.id ||= next_id
    all[idea.id] = idea
    idea.id
  end

  def self.find(id)
    all[id]
  end

  def self.next_id
    all.size
  end

  def self.count
    all.length
  end

  def self.delete_all
    @all = []
  end

  def self.find_by_title(text)
    all.find do |idea|
      idea.title == text
    end
  end

  def self.delete(id)
    all.delete_at(id)
  end

  def self.all
    @all ||= []
  end

end
