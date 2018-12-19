class AutocloseAbandoned < ActiveRecord::Migration[5.1]
  def up
    Scheduler.create_if_not_exists(
      name: 'Close abandoned tickets',
      method: 'Ticket.process_abandoned',
      period: 6.hours,
      prio: 1,
      active: true,
      updated_by_id: 1,
      created_by_id: 1,
    )
    Cache.clear
  end

end
