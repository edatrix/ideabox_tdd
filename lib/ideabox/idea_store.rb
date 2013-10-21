class IdeaStore

  def self.save(idea)
    @all ||= []
    id = next_id
    @all << idea
    id
  end

  def self.find(id)
    @all[id]
  end

  def self.next_id
    @all.size
  end

  def self.count
    @all.length
  end

  def self.delete_all
    @all = []
  end

end