require 'money'

module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Money #:nodoc:
      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def money(name, options = {})
          allow_nil  = options.has_key?(:allow_nil) ? options.delete(:allow_nil) : true
          field_name = options[:cents] || "#{name}_in_cents"
          precision  = options[:precision] || 2
          currency   = (options[:currency] || ::Money.default_currency).to_s
          rounding   = options[:round]

          define_method "#{name}" do
            val = self.read_attribute(field_name)
            val ? ::Money.new(self.read_attribute(field_name), currency, precision) : val
          end

          define_method "#{name}=" do |val|
            val = 0 if !allow_nil && val.blank?
            val = BigDecimal.new(val.to_s).to_money(precision).round(rounding || precision)
            self.send(:write_attribute, field_name, val.cents)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Money
