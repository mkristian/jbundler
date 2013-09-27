#!/bin/bash

for f in spec/*_spec.rb ; do
  echo
  echo $f
  echo '--------------------------'
  ruby $f || exit 1
done

mvn test && bundle exec rake
