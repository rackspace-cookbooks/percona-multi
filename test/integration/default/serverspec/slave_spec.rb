# Encoding: utf-8

require_relative 'spec_helper'

describe user('mysql') do
  it { should exist }
end
