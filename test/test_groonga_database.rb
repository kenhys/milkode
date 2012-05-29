# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'test_helper'
require 'milkode/database/groonga_database'
require 'milkode/common/dbdir'

module Milkode
  class TestGroongaDatabase < Test::Unit::TestCase
    def test_database
      begin
        t_setup
        t_open
        t_packages
        t_packages_viewtime
      ensure
        t_cleanup
      end
    end

    def t_setup
      @obj = GroongaDatabase.new
      @tmp_dir = File.join(File.dirname(__FILE__), "groonga_database_work")
    end
    
    def t_cleanup
      # 本当は明示的にcloseした方が行儀が良いのだけれど、
      # 単体テストの時にSementationFaultが出るのでコメントアウト
      # @obj.close

      # データベース削除
      @obj = nil
      FileUtils.rm_rf(@tmp_dir)
    end

    def t_open
      @obj.open(@tmp_dir)
      # @obj.close
    end

    def t_packages
      # @obj.open(@tmp_dir)

      packages = @obj.packages
      assert_equal 0, packages.size

      packages.add("milkode")
      assert_equal 1, packages.size

      r = packages["milkode"]
      assert_equal "milkode", r.name
      assert r.addtime.to_i  > 0
      assert_equal 0, r.updatetime.to_i
      assert_equal 0, r.viewtime.to_i
      assert_equal 0, r.favtime.to_i

      packages.remove("milkode")
      assert_equal 0, packages.size
    end
    
    def t_packages_viewtime
      packages = @obj.packages
      packages.add("add")
      packages.add("update")
      packages.add("view")
      packages.add("favorite")
      assert_equal 4, packages.size

      packages.each do |r|
        # p r
      end

      r = packages["update"]
      r.updatetime = Time.now
      
      r = packages["view"]
      r.viewtime = Time.now

      r = packages["favorite"]
      r.favtime = Time.now
      
      # packages.dump

      assert_not_equal 0, packages["update"].updatetime
      assert_not_equal 0, packages["view"].viewtime
      assert_not_equal 0, packages["favorite"].favtime

      packages.remove_all
      assert_equal 0, packages.size
    end
  end
end
