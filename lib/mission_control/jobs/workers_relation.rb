# A relation of workers.
#
# Relations are enumerable, so you can use +Enumerable+ methods on them.
# Notice however that using these methods will imply loading all the relation
# in memory, which could introduce performance concerns.
class MissionControl::Jobs::WorkersRelation
  include Enumerable

  attr_accessor :offset_value, :limit_value

  delegate :last, :[], :count, :empty?, :length, :size, :to_s, :inspect, :reverse, to: :to_a

  ALL_WORKERS_LIMIT = 100_000_000 # When no limit value it defaults to "all workers"

  def initialize(queue_adapter:)
    @queue_adapter = queue_adapter

    set_defaults
  end

  def offset(offset)
    clone_with offset_value: offset
  end

  def limit(limit)
    clone_with limit_value: limit
  end

  def each(&block)
    workers.each(&block)
  end

  def reload
    @count = nil
    self
  end

  private
    def set_defaults
      self.offset_value = 0
      self.limit_value = ALL_WORKERS_LIMIT
    end

    def workers
      @workers ||= @queue_adapter.fetch_workers(self)
    end

    def clone_with(**properties)
      dup.reload.tap do |relation|
          properties.each do |key, value|
              relation.send("#{key}=", value)
          end
      end
    end
end
