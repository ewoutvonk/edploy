# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/transformer'

class TestTransformer < Test::Unit::TestCase

  DPLOYIFY_SETTINGS = {
    :roles => {
      :app => {
        :hosts => [ "app1.tld", "app2.tld" ]
      }
    },
    :servers => {
      "my.server.tld" => {
        :roles => [ :web, :app, :db ]
      }
    },
    :stages => {
      :staging => {
        :roles => {
          :db => {
            :hosts => [ "db1.tld", "db2.tld" ],
            :options => {
              :primary => true
            }
          }
        },
        :servers => {
          "indexer.tld" => {
            :roles => [ :indexing, :app ],
            :options => {
              :main_indexer => true
            }
          }
        }
      }
    }
  }
  
  def assert_role(hsh, key, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    hosts = args
    assert hsh.has_key?(key)
    assert_equal Role, hsh[key].class
    assert_equal options, hsh[key].options
    hosts.each do |host|
      assert hsh[key].hosts.include?(host), "Role hosts #{hsh[key].hosts.to_s} does not contain host #{host}"
    end
  end
  
  def assert_server(hsh, key, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    roles = args
    assert hsh.has_key?(key)
    assert_equal Server, hsh[key].class
    assert_equal options, hsh[key].options
    roles.each do |role|
      assert hsh[key].roles.include?(role), "Server roles #{hsh[key].roles.to_s} does not contain role #{role}"
    end
  end

  def test_parse_with_transform_settings
    settings = DPLOYIFY_SETTINGS
    Dployify::Transformer.transform_settings(settings)
    assert_role settings, :app, "app1.tld", "app2.tld"
    assert_server settings, "my.server.tld", :web, :app, :db
    assert_role settings[:stages][:staging], :db, "db1.tld", "db2.tld", :primary => true
    assert_server settings[:stages][:staging], "indexer.tld", :indexing, :app, :main_indexer => true
  end
  
end