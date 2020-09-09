# frozen_string_literal: true

require "spec_helper"
require "dependabot/terraform/file_fetcher"
require_common_spec "file_fetchers/shared_examples_for_file_fetchers"

RSpec.describe Dependabot::Terraform::FileFetcher do
  it_behaves_like "a dependency file fetcher"

  let(:source) do
    Dependabot::Source.new(
      provider: "github",
      repo: "gocardless/bump",
      directory: directory
    )
  end
  let(:file_fetcher_instance) do
    described_class.new(source: source, credentials: credentials)
  end
  let(:directory) { "/" }
  let(:github_url) { "https://api.github.com/" }
  let(:url) { github_url + "repos/gocardless/bump/contents/" }
  let(:credentials) do
    [{
      "type" => "git_source",
      "host" => "github.com",
      "username" => "x-access-token",
      "password" => "token"
    }]
  end

  before { allow(file_fetcher_instance).to receive(:commit).and_return("sha") }

  context "with a Terraform 011 file" do
    before do
      stub_request(:get, url + "?ref=sha").
        with(headers: { "Authorization" => "token token" }).
        to_return(
          status: 200,
          body: fixture("github", "contents_terraform_011_repo.json"),
          headers: { "content-type" => "application/json" }
        )

      %w(main.tf outputs.tf variables.tf).each do |nm|
        stub_request(:get, File.join(url, "#{nm}?ref=sha")).
          with(headers: { "Authorization" => "token token" }).
          to_return(
            status: 200,
            body: fixture("github", "contents_terraform_011_file.json"),
            headers: { "content-type" => "application/json" }
          )
      end
    end

    it "fetches the Terraform files" do
      expect(file_fetcher_instance.files.map(&:name)).
        to match_array(%w(main.tf outputs.tf variables.tf))
    end
  end

  context "with a Terraform 012 file" do
    before do
      stub_request(:get, url + "?ref=sha").
        with(headers: { "Authorization" => "token token" }).
        to_return(
          status: 200,
          body: fixture("github", "contents_terraform_012_repo.json"),
          headers: { "content-type" => "application/json" }
        )

      %w(main.tf outputs.tf variables.tf).each do |nm|
        stub_request(:get, File.join(url, "#{nm}?ref=sha")).
          with(headers: { "Authorization" => "token token" }).
          to_return(
            status: 200,
            body: fixture("github", "contents_terraform_012_file.json"),
            headers: { "content-type" => "application/json" }
          )
      end
    end

    it "fetches the Terraform files" do
      expect(file_fetcher_instance.files.map(&:name)).
        to match_array(%w(main.tf outputs.tf variables.tf))
    end
  end

  context "with a Terragrunt Legacy file" do
    before do
      stub_request(:get, url + "?ref=sha").
        with(headers: { "Authorization" => "token token" }).
        to_return(
          status: 200,
          body: fixture("github", "contents_terragrunt_legacy_repo.json"),
          headers: { "content-type" => "application/json" }
        )

      stub_request(:get, File.join(url, "terraform.tfvars?ref=sha")).
        with(headers: { "Authorization" => "token token" }).
        to_return(
          status: 200,
          body: fixture("github", "contents_terraform_011_file.json"),
          headers: { "content-type" => "application/json" }
        )
    end

    it "fetches the Terragrunt file" do
      expect(file_fetcher_instance.files.map(&:name)).
        to match_array(%w(terraform.tfvars))
    end
  end

  context "with a Terragrunt file" do
    before do
      stub_request(:get, url + "?ref=sha").
        with(headers: { "Authorization" => "token token" }).
        to_return(
          status: 200,
          body: fixture("github", "contents_terragrunt_repo.json"),
          headers: { "content-type" => "application/json" }
        )

      stub_request(:get, File.join(url, "terragrunt.hcl?ref=sha")).
        with(headers: { "Authorization" => "token token" }).
        to_return(
          status: 200,
          body: fixture("github", "contents_terraform_012_file.json"),
          headers: { "content-type" => "application/json" }
        )
    end

    it "fetches the Terragrunt file" do
      expect(file_fetcher_instance.files.map(&:name)).
        to match_array(%w(terragrunt.hcl))
    end
  end

  context "with a directory that doesn't exist" do
    let(:directory) { "/nonexistent" }

    before do
      stub_request(:get, url + "nonexistent?ref=sha").
        with(headers: { "Authorization" => "token token" }).
        to_return(
          status: 404,
          body: fixture("github", "not_found.json"),
          headers: { "content-type" => "application/json" }
        )
    end

    it "raises a helpful error" do
      expect { file_fetcher_instance.files }.
        to raise_error(Dependabot::DependencyFileNotFound)
    end
  end
end
