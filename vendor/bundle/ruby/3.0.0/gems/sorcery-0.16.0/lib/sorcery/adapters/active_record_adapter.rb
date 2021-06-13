module Sorcery
  module Adapters
    class ActiveRecordAdapter < BaseAdapter
      def update_attributes(attrs)
        attrs.each do |name, value|
          # name = password
          @model.send(:"#{name}=", value)
        end
        primary_key = @model.class.primary_key
        # where(id => user.id)
        updated_count = @model.class.where(:"#{primary_key}" => @model.send(:"#{primary_key}")).update_all(attrs)
        updated_count == 1
      end

      def save(options = {})
        # raise_on_failure が true の時は、 save! が走るようになる
        mthd = options.delete(:raise_on_failure) ? :save! : :save
        # options には、 validates: false など入ってくる　<- ここでは、関係なさそう
        @model.send(mthd, **options)
      end

      # 何に使うかわからない
      def increment(field)
        @model.increment!(field)
      end

      def find_authentication_by_oauth_credentials(relation_name, provider, uid)
        # user_class は認証を効かせるModel: 今回は、User です
        @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
        conditions = {
          @user_config.provider_uid_attribute_name => uid,
          @user_config.provider_attribute_name     => provider
        }
        # User.authentications.where()
        # users(table) has_many twitters(table), facebooks(table)

        # twitters table
        #   t.uid :string
        #   t.provider :string

        # User.twitters.
        @model.public_send(relation_name).where(conditions).first
      end

      class << self
        # これが何なのかわからない、rails/rails 検索してもなかった
        # mongoid_adapter.rb で difine_field が定義されている。おそらく、ダックタイピングしたいからこうしているかもしれない
        # https://github.com/ruby-protobuf/protobuf/blob/4f45a8a44cb864a561fc7988994c4886bf22453b/lib/protobuf/message/fields.rb#L128
        def define_field(name, type, options = {})
          # AR fields are defined through migrations, only validator here
        end

        def define_callback(time, event, method_name, options = {})
          @klass.send "#{time}_#{event}", method_name, **options.slice(:if, :on)
        end

        def find_by_oauth_credentials(provider, uid)
          @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
          conditions = {
            @user_config.provider_uid_attribute_name => uid,
            @user_config.provider_attribute_name     => provider
          }

          @klass.where(conditions).first
        end

        def find_by_remember_me_token(token)
          @klass.where(@klass.sorcery_config.remember_me_token_attribute_name => token).first
        end

        def find_by_credentials(credentials)
          relation = nil
          username_attribute_names = [:email]
          @klass.sorcery_config.username_attribute_names.each do |attribute|
            if @klass.sorcery_config.downcase_username_before_authenticating
              # lower は 小文字にするやつ
              # lower に引数渡したらどうなるの？
              # 6/13 はここまで、来週はここのわからないところからやっていく
              condition = @klass.arel_table[attribute].lower.eq(@klass.arel_table.lower(credentials[0]))
            else
              # "email = 〇〇"
              condition = @klass.arel_table[attribute].eq(credentials[0])
            end

            relation = if relation.nil?
                         condition
                       else
                         relation.or(condition)
                       end
          end

          @klass.where(relation).first
        end

        def find_by_token(token_attr_name, token)
          condition = @klass.arel_table[token_attr_name].eq(token)

          @klass.where(condition).first
        end

        def find_by_activation_token(token)
          @klass.where(@klass.sorcery_config.activation_token_attribute_name => token).first
        end

        def find_by_id(id)
          @klass.find_by_id(id)
        end

        def find_by_username(username)
          @klass.sorcery_config.username_attribute_names.each do |attribute|
            if @klass.sorcery_config.downcase_username_before_authenticating
              username = username.downcase
            end

            result = @klass.where(attribute => username).first
            return result if result
          end
        end

        def find_by_email(email)
          @klass.where(@klass.sorcery_config.email_attribute_name => email).first
        end

        def transaction(&blk)
          @klass.tap(&blk)
        end
      end
    end
  end
end
