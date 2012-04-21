require "spec_helper"

describe "bundle ruby" do
  it "returns ruby version when explicit" do
    gemfile <<-G
      source "file://#{gem_repo1}"
      ruby_version "1.9.3", :engine => 'ruby', :engine_version => '1.9.3'

      gem "foo"
    G

    bundle "ruby"

    out.should eq("ruby 1.9.3 (ruby 1.9.3)")
  end

  it "engine defaults to MRI" do
    gemfile <<-G
      source "file://#{gem_repo1}"
      ruby_version "1.9.3"

      gem "foo"
    G

    bundle "ruby"

    out.should eq("ruby 1.9.3 (ruby 1.9.3)")
  end

  it "handles jruby" do
    gemfile <<-G
      source "file://#{gem_repo1}"
      ruby_version "1.8.7", :engine => 'jruby', :engine_version => '1.6.5'

      gem "foo"
    G

    bundle "ruby"

    out.should eq("ruby 1.8.7 (jruby 1.6.5)")
  end

  it "handles rbx" do
    gemfile <<-G
      source "file://#{gem_repo1}"
      ruby_version "1.8.7", :engine => 'rbx', :engine_version => '1.2.4'

      gem "foo"
    G

    bundle "ruby"

    out.should eq("ruby 1.8.7 (rbx 1.2.4)")
  end

  it "raises an error if engine is used but engine version is not" do
    gemfile <<-G
      source "file://#{gem_repo1}"
      ruby_version "1.8.7", :engine => 'rbx'

      gem "foo"
    G

    bundle "ruby", :exitstatus => true

    exitstatus.should_not == 0
  end

  it "raises an error if engine_version is used but engine is not" do
    gemfile <<-G
      source "file://#{gem_repo1}"
      ruby_version "1.8.7", :engine_version => '1.2.4'

      gem "foo"
    G

    bundle "ruby", :exitstatus => true

    exitstatus.should_not == 0
  end

  it "raises an error if engine version doesn't match ruby version for mri" do
    gemfile <<-G
      source "file://#{gem_repo1}"
      ruby_version "1.8.7", :engine => 'ruby', :engine_version => '1.2.4'

      gem "foo"
    G

    bundle "ruby", :exitstatus => true

    exitstatus.should_not == 0
  end

  context "bundle install" do
    it "installs fine when the ruby version matches" do
      install_gemfile <<-G
        source "file://#{gem_repo1}"
        gem "rack"

        ruby_version "#{RUBY_VERSION}", :engine => "#{local_ruby_engine}", :engine_version => "#{local_engine_version}"
      G

      bundled_app('Gemfile.lock').should exist
    end

    it "doesn't install when the ruby version doesn't match" do
      install_gemfile <<-G
        source "file://#{gem_repo1}"
        gem "rack"

        ruby_version "#{not_local_ruby_version}", :engine => "#{local_ruby_engine}", :engine_version => "#{not_local_ruby_version}"
      G

      bundled_app('Gemfile.lock').should_not exist
      out.should == "Your Ruby version is #{RUBY_VERSION}, but your Gemfile specified #{not_local_ruby_version}"
    end

    it "doesn't install when engine doesn't match" do
      install_gemfile <<-G
        source "file://#{gem_repo1}"
        gem "rack"

        ruby_version "#{RUBY_VERSION}", :engine => "#{not_local_tag}", :engine_version => "#{RUBY_VERSION}"
      G

      bundled_app('Gemfile.lock').should_not exist
      out.should == "Your Ruby engine is #{local_ruby_engine}, but your Gemfile specified #{not_local_tag}"
    end

    it "doesn't install when engine version doesn't match" do
      simulate_ruby_engine "jruby" do
        install_gemfile <<-G
          source "file://#{gem_repo1}"
          gem "rack"

          ruby_version "#{RUBY_VERSION}", :engine => "#{local_ruby_engine}", :engine_version => "#{not_local_engine_version}"
        G

        bundled_app('Gemfile.lock').should_not exist
        out.should == "Your #{local_ruby_engine} version is #{local_engine_version}, but your Gemfile specified #{local_ruby_engine} #{not_local_engine_version}"
      end
    end
  end
end