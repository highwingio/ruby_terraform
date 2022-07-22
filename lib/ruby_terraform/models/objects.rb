# frozen_string_literal: true

require_relative './values'

module RubyTerraform
  module Models
    # rubocop:disable Metrics/ModuleLength
    module Objects
      class << self
        # rubocop:disable Style/RedundantAssignment
        def box(object, unknown: nil, sensitive: nil)
          initial = boxed_empty_by_value(object)
          object = symbolise(object)
          unknown = symbolised_or_native_empty(unknown, object)
          sensitive = symbolised_or_native_empty(sensitive, object)

          return Values.unknown(sensitive: sensitive) if unknown == true

          boxed_unknown =
            box_unknown(unknown, sensitive: sensitive, initial: initial)
          boxed_object =
            box_known(object, sensitive: sensitive, initial: boxed_unknown)

          boxed_object
        end

        # rubocop:enable Style/RedundantAssignment

        def paths(object, current = [], accumulator = [])
          normalised = normalise(object)
          if normalised.is_a?(Enumerable)
            normalised.inject(accumulator) do |a, e|
              paths(e[0], current + [e[1]], a)
            end
          else
            accumulator + [current]
          end
        end

        def known_values(paths, object: {}, sensitive: {})
          paths.map do |path|
            resolved = try_dig(object, path)
            resolved_sensitive = try_dig(sensitive, path) == true

            Values.known(resolved, sensitive: resolved_sensitive)
          end
        end

        def unknown_values(paths, unknown: {}, sensitive: {})
          paths.map do |path|
            resolved = try_dig(unknown, path)
            resolved_sensitive = try_dig(sensitive, path) == true

            resolved ? Values.unknown(sensitive: resolved_sensitive) : nil
          end
        end

        def object(paths, values, sensitive: {}, initial: Values.empty_map)
          paths
            .zip(values)
            .each_with_object(initial) do |path_value, object|
            path, value = path_value
            update_in(object, path, value, sensitive: sensitive)
          end
        end

        private

        # rubocop:disable Metrics/MethodLength
        def box_unknown(unknown, sensitive: {}, initial: Values.empty_map)
          unknown_paths = paths(unknown)
          if root_path(unknown_paths)
            return Values.unknown(sensitive: sensitive)
          end

          unknown_values = unknown_values(
            unknown_paths, unknown: unknown, sensitive: sensitive
          )

          object(
            unknown_paths, unknown_values,
            sensitive: sensitive, initial: initial
          )
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def box_known(object, sensitive: {}, initial: Values.empty_map)
          object_paths = paths(object)
          if root_path(object_paths)
            return Values.known(object, sensitive: sensitive)
          end

          object_values = known_values(
            object_paths, object: object, sensitive: sensitive
          )

          object(
            object_paths, object_values,
            sensitive: sensitive, initial: initial
          )
        end
        # rubocop:enable Metrics/MethodLength

        def update_in(object, path, value, sensitive: {})
          path.inject([[], path.drop(1)]) do |context, step|
            seen, remaining = context
            pointer = [seen, step, remaining]

            update_object_for_step(object, pointer, value, sensitive: sensitive)
            update_context_for_step(pointer)
          end
          object
        end

        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def update_object_for_step(object, pointer, value, sensitive: {})
          seen, step, remaining = pointer

          parent = try_dig(object, seen, default: object)
          upcoming = remaining.first

          resolved_sensitive = try_dig(sensitive, seen + [step]) == true
          resolved =
            if remaining.empty?
              value
            else
              boxed_empty_by_key(upcoming, sensitive: resolved_sensitive)
            end

          if step.is_a?(Numeric) && highest_index(parent) < step
            add_omitted_items_if_needed(parent, step)
          end

          if parent[step].is_a?(OmittedValue)
            parent[step] = resolved
          else
            parent[step] ||= resolved
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def update_context_for_step(pointer)
          seen, step, remaining = pointer
          [seen + [step], remaining.drop(1)]
        end

        def add_omitted_items_if_needed(parent, step)
          (0...step).each do |i|
            parent[i] = Values.omitted if parent[i].nil?
          end
        end

        def try_dig(object, path, default: nil)
          return default if path.empty?

          result = object.dig(*path)
          result.nil? ? default : result
        rescue NoMethodError, TypeError
          default
        end

        def boxed_empty_by_key(key, sensitive: false)
          if key.is_a?(Numeric)
            Values.empty_list(sensitive: sensitive)
          else
            Values.empty_map(sensitive: sensitive)
          end
        end

        def boxed_empty_by_value(value, sensitive: false)
          case value
          when Array then Values.empty_list(sensitive: sensitive)
          when Hash then Values.empty_map(sensitive: sensitive)
          end
        end

        def native_empty_by_value(value)
          case value
          when Array then []
          when Hash then {}
          else false
          end
        end

        def normalise(object)
          case object
          when Array then object.each_with_index.to_a
          when Hash
            object.to_a.map do |e|
              [e[1], e[0].to_sym]
            end
          else object
          end
        end

        def symbolise(object)
          case object
          when Hash
            object.to_h { |key, value| [key.to_sym, symbolise(value)] }
          else object
          end
        end

        def symbolised_or_native_empty(object, target)
          object ? symbolise(object) : native_empty_by_value(target)
        end

        def root_path(paths)
          paths.count == 1 && paths[0].empty?
        end

        def highest_index(array)
          element_indices = array.each_with_index.to_a
          return -1 if element_indices.empty?

          element_indices.last.last
        end
      end
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
