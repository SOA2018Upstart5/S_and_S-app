# frozen_string_literal: true

folders = %w[controllers forms services representers values]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
