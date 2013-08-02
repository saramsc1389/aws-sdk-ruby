# Copyright 2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

module Seahorse
  module Client
    class Plugin

      # @param [Configuration] config
      # @return [void]
      def add_options(config)
        self.class.options.each do |option|
          name, default = option
          default = instance_exec(config, &default) if default.is_a?(Proc)
          config.add_option(name, default)
        end
      end

      # @param [HandlerList] handlers
      # @param [Configuration] config
      # @return [void]
      def add_handlers(handlers, config)
        self.class.handlers.each do |handler_class, options|
          handlers.add(handler_class, options)
        end
      end

      class << self

        # (see Configuration#add_option)
        def option(name, default = nil, &block)
          if block_given?
            options << [name, Proc.new]
          else
            options << [name, default]
          end
        end

        # @overload handler(options = {}, &handler_block)
        #   @option options [Symbol] priority (:build)
        #
        # @overload handler(handler_name, options = {}, &handler_block)
        #   @param [String] handler_name
        #   @option options [Symbol] priority (:build)
        #
        # @overload handler(handler_class, options = {})
        #   @param [Class] handler_class
        #   @option options [Symbol] priority (:build)
        #
        def handler(*args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}
          if block_given?
            handlers << [handler_from_proc(args.first, &block), options]
          else
            handlers << [args.first, options]
          end
        end

        # @api private
        def options
          @options ||= []
        end

        # @api private
        def handlers
          @handlers ||= []
        end

        # @api private
        def handler_from_proc(name = nil, &block)
          if name
            const_set(name, new_handler(&block))
          else
            new_handler(&block)
          end
        end

        # @api private
        def new_handler(&block)
          Class.new(Handler) do
            define_method(:call, &block)
          end
        end

      end
    end
  end
end
