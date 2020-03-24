def migrating?
  running_tasks = Rake.application.top_level_tasks || []
  running_tasks.any? { |task_name| migration_task? task_name }
end

def migration_task?(task_name)
  %w[db: zammad:db].any? { |migration_task_prefix| task_name.start_with? migration_task_prefix }
end

if migrating?
  print "Skipping telegram update listener while migrating database\n"
  return
end

Rails.application.config.after_initialize do
  print "Initializing telegram update listener\n"
  TelegramUpdatePuller.instance.listen_all_channels
end
