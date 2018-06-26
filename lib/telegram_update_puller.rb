class TelegramUpdatePuller
  include Singleton

  def initialize
    @channels = {}
  end

  def listen_all_channels
    logger.info 'Starting listening all telegram channels for updates'

    all_active_telegram_channels.each do |channel|
      listen channel
    end
  end

  def stop_listening(channel)
    if listening? channel
      bot_id = bot_id channel

      logger.info "Stopping listening telegram channel #{bot_id} for updates"
      @channels[bot_id].kill
    end
  end

  def listen(channel)
    bot_id = bot_id channel
    token = token(channel)

    api = TelegramAPI.new token
    telegram = Telegram.new token

    stop_listening channel if listening? channel

    @channels[bot_id] = Thread.new do
      logger.info "Starting listening telegram channel #{bot_id} for updates"

      while true do
        begin
          updates = api.getUpdates('timeout' => 180)

          updates.each do |update|
            user = update['message']['chat']['username'] || 'unknown'

            logger.debug "Channel #{bot_id} updated by user #{user}"
            logger.debug update

            telegram.to_group(HashWithIndifferentAccess.new(update), channel.group_id, channel)
          end
        rescue => e
          logger.error e
        end
      end
    end
  end

  private

  def normalize_message(message)
    # message['message']['text'] = message['text']
  end

  def all_active_telegram_channels
    Channel.where(area: 'Telegram::Bot').all.select do |channel|
      telegram_channel?(channel) && channel.active?
    end
  end

  def telegram_channel?(channel)
    channel.options && channel.options[:bot] && channel.options[:bot][:id] && channel.options[:api_token]
  end

  def bot_id(channel)
    channel.options[:bot][:id]
  end

  def token(channel)
    channel.options[:api_token]
  end

  def listening?(channel)
    @channels.key? bot_id(channel)
  end

  def logger
    Rails.logger
  end
end