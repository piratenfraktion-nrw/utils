#!/usr/bin/env ruby1.9.3
# encoding: utf-8


def read_config(file, options)
  unless file.file?
    puts "config #{file} not found"
    exit
  end

  options_kv = {}

  file.open do |f|
    line = f.read

    options.each do |opt|
      opt_re = /^#{opt}\s*=\s*"(.+)"\s*$/i
      options_kv[opt.to_sym] = line.match(opt_re)[1] if line =~ opt_re
    end
  end

  return options_kv
end


