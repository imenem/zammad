class AddCustomerInfoProviderSetting < ActiveRecord::Migration[5.1]
  def up

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    Setting.create_if_not_exists(
        title: 'Customer Info Provider',
        name: 'customer_info_provider',
        area: 'System::Services',
        description: 'Defines the backend that provides customer info by telegram chat ID.',
        options: {
            form: [
                {
                    display: '',
                    null: true,
                    name: 'customer_info_provider',
                    tag: 'input'
                }
            ]
        },
        preferences: {
            prio: 3,
            placeholder: true,
            permission: ['admin.system'],
        },
        frontend: true
    )
  end
end