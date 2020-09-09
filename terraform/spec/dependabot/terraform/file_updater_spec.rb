# frozen_string_literal: true

require "spec_helper"
require "dependabot/dependency"
require "dependabot/dependency_file"
require "dependabot/terraform/file_updater"
require_common_spec "file_updaters/shared_examples_for_file_updaters"

RSpec.describe Dependabot::Terraform::FileUpdater do
  it_behaves_like "a dependency file updater"

  let(:updater) do
    described_class.new(
      dependency_files: files,
      dependencies: [dependency],
      credentials: credentials
    )
  end
  let(:files) { [terraform_config, irrelevant_config] }
  let(:credentials) do
    [{
      "type" => "git_source",
      "host" => "github.com",
      "username" => "x-access-token",
      "password" => "token"
    }]
  end
  let(:irrelevant_config) do
    Dependabot::DependencyFile.new(
      name: "other.tf",
      content: fixture("config_files", "registry_011.tf")
    )
  end
  let(:terraform_config) do
    Dependabot::DependencyFile.new(
      name: "main.tf",
      content: terraform_body
    )
  end
  let(:terraform_body) { fixture("config_files", "git_tags_011.tf") }
  let(:dependency) do
    Dependabot::Dependency.new(
      name: "origin_label",
      version: "0.4.1",
      previous_version: "0.3.7",
      requirements: [{
        requirement: nil,
        groups: [],
        file: "main.tf",
        source: {
          type: "git",
          url: "https://github.com/cloudposse/terraform-null-label.git",
          branch: nil,
          ref: "tags/0.4.1"
        }
      }],
      previous_requirements: [{
        requirement: nil,
        groups: [],
        file: "main.tf",
        source: {
          type: "git",
          url: "https://github.com/cloudposse/terraform-null-label.git",
          branch: nil,
          ref: "tags/0.3.7"
        }
      }],
      package_manager: "terraform"
    )
  end

  describe "#updated_dependency_files" do
    subject(:updated_files) { updater.updated_dependency_files }

    it "returns DependencyFile objects" do
      updated_files.each { |f| expect(f).to be_a(Dependabot::DependencyFile) }
    end

    its(:length) { is_expected.to eq(1) }

    describe "the updated file" do
      subject(:updated_file) { updated_files.find { |f| f.name == "main.tf" } }

      context "with a git dependency" do
        it "updates the requirement" do
          expect(updated_file.content).to include(
            "module \"origin_label\" {\n"\
            "  source     = \"git::https://github.com/cloudposse/"\
            "terraform-null-label.git?ref=tags/0.4.1\"\n"
          )
        end

        it "doesn't update the duplicate" do
          expect(updated_file.content).to include(
            "module \"duplicate_label\" {\n"\
            "  source     = \"git::https://github.com/cloudposse/"\
            "terraform-null-label.git?ref=tags/0.3.7\"\n"
          )
        end
      end

      context "with a registry dependency" do
        let(:terraform_body) do
          fixture("config_files", "registry_011.tf")
        end
        let(:dependency) do
          Dependabot::Dependency.new(
            name: "hashicorp/consul/aws",
            version: "0.3.1",
            previous_version: "0.1.0",
            requirements: [{
              requirement: "0.3.1",
              groups: [],
              file: "main.tf",
              source: {
                type: "registry",
                registry_hostname: "registry.terraform.io",
                module_identifier: "hashicorp/consul/aws"
              }
            }],
            previous_requirements: [{
              requirement: "0.1.0",
              groups: [],
              file: "main.tf",
              source: {
                type: "registry",
                registry_hostname: "registry.terraform.io",
                module_identifier: "hashicorp/consul/aws"
              }
            }],
            package_manager: "terraform"
          )
        end

        it "updates the requirement" do
          expect(updated_file.content).to include(
            "module \"consul\" {\n"\
            "  source  = \"hashicorp/consul/aws\"\n"\
            "  version = \"0.3.1\"\n"\
            "}"
          )
        end
      end

      context "with a terragrunt file" do
        subject(:updated_file) do
          updated_files.find { |f| f.name == "main.tfvars" }
        end

        let(:files) { [terragrunt_config, irrelevant_config] }
        let(:terragrunt_config) do
          Dependabot::DependencyFile.new(
            name: "main.tfvars",
            content: fixture("config_files", "terragrunt.tfvars")
          )
        end

        let(:dependency) do
          Dependabot::Dependency.new(
            name: "gruntwork-io/modules-example",
            version: "0.0.5",
            previous_version: "0.0.2",
            requirements: [{
              requirement: nil,
              groups: [],
              file: "main.tfvars",
              source: {
                type: "git",
                url: "git@github.com:gruntwork-io/modules-example.git",
                branch: nil,
                ref: "v0.0.5"
              }
            }],
            previous_requirements: [{
              requirement: nil,
              groups: [],
              file: "main.tfvars",
              source: {
                type: "git",
                url: "git@github.com:gruntwork-io/modules-example.git",
                branch: nil,
                ref: "v0.0.2"
              }
            }],
            package_manager: "terraform"
          )
        end

        it "updates the requirement" do
          expect(updated_file.content).to include(
            "source = \"git::git@github.com:gruntwork-io/modules-example.git//"\
            "consul?ref=v0.0.5\""
          )
        end
      end
    end
  end
end

RSpec.describe Dependabot::Terraform::FileUpdater do
  it_behaves_like "a dependency file updater"

  let(:updater) do
    described_class.new(
      dependency_files: files,
      dependencies: [dependency],
      credentials: credentials
    )
  end
  let(:files) { [terraform_config, irrelevant_config] }
  let(:credentials) do
    [{
      "type" => "git_source",
      "host" => "github.com",
      "username" => "x-access-token",
      "password" => "token"
    }]
  end
  let(:irrelevant_config) do
    Dependabot::DependencyFile.new(
      name: "other.tf",
      content: fixture("config_files", "registry_012.tf")
    )
  end
  let(:terraform_config) do
    Dependabot::DependencyFile.new(
      name: "main.tf",
      content: terraform_body
    )
  end
  let(:terraform_body) { fixture("config_files", "git_tags_012.tf") }
  let(:dependency) do
    Dependabot::Dependency.new(
      name: "origin_label",
      version: "0.4.1",
      previous_version: "0.3.7",
      requirements: [{
        requirement: nil,
        groups: [],
        file: "main.tf",
        source: {
          type: "git",
          url: "https://github.com/cloudposse/terraform-null-label.git",
          branch: nil,
          ref: "0.4.1"
        }
      }],
      previous_requirements: [{
        requirement: nil,
        groups: [],
        file: "main.tf",
        source: {
          type: "git",
          url: "https://github.com/cloudposse/terraform-null-label.git",
          branch: nil,
          ref: "0.3.7"
        }
      }],
      package_manager: "terraform"
    )
  end

  describe "#updated_dependency_files" do
    subject(:updated_files) { updater.updated_dependency_files }

    it "returns DependencyFile objects" do
      updated_files.each { |f| expect(f).to be_a(Dependabot::DependencyFile) }
    end

    its(:length) { is_expected.to eq(1) }

    describe "the updated file" do
      subject(:updated_file) { updated_files.find { |f| f.name == "main.tf" } }

      context "with a git dependency" do
        it "updates the requirement" do
          expect(updated_file.content).to include(
            "module \"origin_label\" {\n"\
            "  source     = \"git::https://github.com/cloudposse/"\
            "terraform-null-label.git?ref=0.4.1\"\n"
          )
        end

        it "doesn't update the duplicate" do
          expect(updated_file.content).to include(
            "module \"duplicate_label\" {\n"\
            "  source     = \"git::https://github.com/cloudposse/"\
            "terraform-null-label.git?ref=0.3.7\"\n"
          )
        end
      end

      context "with a registry dependency" do
        let(:terraform_body) do
          fixture("config_files", "registry_011.tf")
        end
        let(:dependency) do
          Dependabot::Dependency.new(
            name: "hashicorp/consul/aws",
            version: "0.3.1",
            previous_version: "0.1.0",
            requirements: [{
              requirement: "0.3.1",
              groups: [],
              file: "main.tf",
              source: {
                type: "registry",
                registry_hostname: "registry.terraform.io",
                module_identifier: "hashicorp/consul/aws"
              }
            }],
            previous_requirements: [{
              requirement: "0.1.0",
              groups: [],
              file: "main.tf",
              source: {
                type: "registry",
                registry_hostname: "registry.terraform.io",
                module_identifier: "hashicorp/consul/aws"
              }
            }],
            package_manager: "terraform"
          )
        end

        it "updates the requirement" do
          expect(updated_file.content).to include(
            "module \"consul\" {\n"\
            "  source  = \"hashicorp/consul/aws\"\n"\
            "  version = \"0.3.1\"\n"\
            "}"
          )
        end
      end

      context "with a terragrunt file" do
        subject(:updated_file) do
          updated_files.find { |f| f.name == "main.tfvars" }
        end

        let(:files) { [terragrunt_config, irrelevant_config] }
        let(:terragrunt_config) do
          Dependabot::DependencyFile.new(
            name: "main.tfvars",
            content: fixture("config_files", "terragrunt.tfvars")
          )
        end

        let(:dependency) do
          Dependabot::Dependency.new(
            name: "gruntwork-io/modules-example",
            version: "0.0.5",
            previous_version: "0.0.2",
            requirements: [{
              requirement: nil,
              groups: [],
              file: "main.tfvars",
              source: {
                type: "git",
                url: "git@github.com:gruntwork-io/modules-example.git",
                branch: nil,
                ref: "v0.0.5"
              }
            }],
            previous_requirements: [{
              requirement: nil,
              groups: [],
              file: "main.tfvars",
              source: {
                type: "git",
                url: "git@github.com:gruntwork-io/modules-example.git",
                branch: nil,
                ref: "v0.0.2"
              }
            }],
            package_manager: "terraform"
          )
        end

        it "updates the requirement" do
          expect(updated_file.content).to include(
            "source = \"git::git@github.com:gruntwork-io/modules-example.git//"\
            "consul?ref=v0.0.5\""
          )
        end
      end
    end
  end
end
