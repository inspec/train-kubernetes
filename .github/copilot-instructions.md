# GitHub Copilot Instructions for Train-Kubernetes Repository

## Repository Overview

**Train-Kubernetes** is a transport plugin for Chef InSpec Train that allows applications to communicate with the Kubernetes API. It enables InSpec to perform compliance checks against any resource in the Kubernetes API. This plugin is distributed as a Ruby gem and is included with InSpec 5.22.0 and later.

### Repository Structure

```
train-kubernetes/
├── .github/                       # GitHub configuration and workflows
│   ├── workflows/                # CI/CD workflow definitions
│   │   ├── ci-main-pull-request-checks.yml
│   │   └── ci-main-pull-request-stub-trufflehog-only.yml
│   └── copilot-instructions.md   # This file
├── .expeditor/                   # Expeditor CI/CD configuration
│   ├── config.yml               # Expeditor configuration
│   ├── coverage.pipeline.yml    # Coverage pipeline
│   ├── run_linux_tests.sh      # Linux test runner
│   ├── run_windows_tests.ps1   # Windows test runner
│   ├── update_version.sh       # Version update script
│   └── verify.pipeline.yml     # Verification pipeline
├── lib/                          # Main library code
│   ├── train-kubernetes.rb      # Entry point - loads plugin components
│   └── train-kubernetes/        # Core library modules
│       ├── connection.rb        # Kubernetes connection implementation
│       ├── kubectl_client.rb    # kubectl client wrapper
│       ├── platform.rb          # Platform detection for Kubernetes
│       ├── transport.rb         # Transport plugin implementation
│       ├── version.rb           # Version information
│       └── file/                # File resource implementations
│           ├── linux.rb         # Linux file operations for containers
│           ├── linux_immutable_file_check.rb  # Immutable file checks
│           └── linux_permissions.rb           # Linux permissions handling
├── test/                         # Test suite
│   ├── helper.rb                # Test helper and setup
│   ├── fixtures/                # Test fixtures and data
│   │   └── kubeconfig          # Sample kubeconfig for testing
│   ├── helpers/                 # Test helper modules
│   │   └── simplecov_minitest.rb  # SimpleCov configuration
│   └── unit/                    # Unit tests
│       ├── connection_test.rb   # Connection tests
│       ├── kubectl_client_test.rb  # kubectl client tests
│       ├── platform_test.rb     # Platform detection tests
│       ├── transport_test.rb    # Transport tests
│       └── file/                # File resource tests
│           ├── linux_immutable_file_check_test.rb
│           └── linux_test.rb
├── .gitignore                   # Git ignore patterns
├── .rubocop.yml                # RuboCop configuration
├── .travis.yml                 # Travis CI configuration (legacy)
├── CHANGELOG.md                # Version history and changes
├── CODE_OF_CONDUCT.md         # Community code of conduct
├── CONTRIBUTING.MD            # Contribution guidelines
├── Gemfile                    # Ruby dependencies
├── LICENSE                    # Apache 2.0 license
├── Rakefile                   # Rake tasks for testing and linting
├── README.md                  # Project documentation
├── sonar-project.properties   # SonarQube configuration
├── train-kubernetes.gemspec   # Gem specification
└── VERSION                    # Current version number
```

## Critical File Modification Rules

### ⚠️ PROHIBITED FILES - DO NOT MODIFY
- **No codegen files**: Do not modify any `*.codegen.go` files if present
- **Built artifacts**: Do not modify `train-kubernetes-*.gem` files - these are built artifacts
- **Lock files**: Be cautious with `Gemfile.lock` modifications
- **Version files**: Do not directly modify `VERSION` file unless specifically updating version
- **GitHub workflows**: Only modify `.github/workflows/` files when explicitly requested
- **Expeditor configs**: Do not modify `.expeditor/` files without understanding CI/CD impact

## Development Workflow

When implementing tasks, follow this complete workflow:

### Phase 1: Task Analysis & Jira Integration

When a Jira ID is provided:
1. **Use MCP Server**: Use the **atlassian-mcp-server** MCP server to fetch Jira issue details
   - Server URL: `https://mcp.atlassian.com/v1/sse`
   - Server type: `http`
2. **Read the story**: Thoroughly read the Jira story requirements
3. **Understand scope**: Understand acceptance criteria and implementation scope
4. **Identify components**: Identify which components need modification (transport, connection, file resources, etc.)
5. **Break down task**: Break down the task into actionable steps

**Step Completion**:
```
✅ Phase 1 Complete: Analyzed Jira ticket [JIRA-ID]
📋 Summary: [Brief summary of requirements]
📝 Components affected: [List of files/modules]
❓ Do you want to continue with the next phase?
```

### Phase 2: Implementation Planning

Before making any code changes:
1. **Analyze codebase**: Review current implementation structure
2. **Identify files**: List all files that need modification
3. **Plan approach**: Design the implementation approach
4. **Check compatibility**: Consider backward compatibility with Train and InSpec
5. **Kubernetes API**: Identify Kubernetes API resources and operations needed
6. **Test scenarios**: Identify comprehensive test scenarios

**Step Completion**:
```
✅ Phase 2 Complete: Implementation plan created
📋 Files to modify: [List of files]
📋 Implementation approach: [Brief description]
📝 Next Phase: Code Implementation
❓ Do you want to continue with the next phase?
```

### Phase 3: Code Implementation

Follow these guidelines:
1. **Ruby standards**: Follow Ruby 3.1+ conventions and project coding standards
2. **Existing patterns**: Maintain consistency with existing code patterns
3. **Train plugin architecture**: Follow Train plugin patterns (Transport, Connection, Platform)
4. **Error handling**: Add appropriate error handling for Kubernetes API failures
5. **Documentation**: Include RDoc comments for public methods
6. **Logging**: Add appropriate logging for debugging
7. **Kubernetes best practices**: Follow Kubernetes API best practices

**Coding Standards**:
- Use meaningful variable and method names
- Keep methods focused and single-purpose
- Handle Kubernetes API errors gracefully
- Support KUBECONFIG environment variable and ~/.kube/config
- Add comprehensive logging for API interactions

**Step Completion**:
```
✅ Phase 3 Complete: Code implementation finished
📋 Files modified: [List of files with brief description of changes]
📝 Next Phase: Testing
❓ Do you want to continue with the next phase?
```

### Phase 4: Testing Requirements

**CRITICAL**: Repository test coverage must ALWAYS be > 80%

For every implementation:
1. **Unit tests**: Create comprehensive unit tests in `test/unit/`
2. **Test coverage**: Ensure new code has > 80% coverage
3. **Mock Kubernetes API**: Use mocks/stubs for Kubernetes API calls in unit tests
4. **Edge cases**: Include edge cases and error scenarios
5. **Test isolation**: Ensure tests are isolated and repeatable
6. **Regression tests**: Run the full test suite to verify no regressions

**Test File Naming Conventions**:
- Unit tests: `test/unit/[module]_test.rb`
- Nested modules: `test/unit/[parent]/[module]_test.rb`

**Test Structure Example**:
```ruby
require "test/helper"

module TrainPlugins
  module TrainKubernetes
    class YourClassTest < Minitest::Test
      def setup
        # Setup logic
      end

      def test_your_functionality
        # Test implementation
      end

      def test_error_handling
        # Test error cases
      end
    end
  end
end
```

**Running Tests**:
```bash
# Run all unit tests
rake test:unit

# Run specific test file
ruby -I lib:test test/unit/your_test.rb

# Run with coverage
CI_ENABLE_COVERAGE=1 rake test:unit
```

**Step Completion**:
```
✅ Phase 4 Complete: Tests implemented and passing
📋 Tests added: [List of test files]
📋 Coverage: [Coverage percentage - must be > 80%]
📋 All tests passing: [Yes/No]
📝 Next Phase: Code Quality & Linting
❓ Do you want to continue with the next phase?
```

### Phase 5: Code Quality & Linting

Before creating PR:
1. **Run RuboCop**: Ensure code follows RuboCop rules
   ```bash
   rake lint
   ```
2. **Fix violations**: Auto-correct RuboCop violations using:
   ```bash
   rake lint:auto_correct
   ```
   Note: Use `rake lint:auto_correct` (NOT `bundle exec rubocop -A`) to ensure consistency with project standards.
3. **Run style check**: Run style checks
   ```bash
   rake style
   ```

**Step Completion**:
```
✅ Phase 5 Complete: Code quality checks passed
📋 RuboCop violations: [Number - should be 0]
📝 Next Phase: Branch Management & PR Creation
❓ Do you want to continue with the next phase?
```

### Phase 6: Branch Management & PR Creation

When creating a PR:

1. **Branch naming**: Use the Jira ID as the branch name (e.g., `CHEF-12345`)
2. **Local development**: All tasks performed on local repository

3. **Git Workflow**:
   ```bash
   # Create and switch to feature branch
   git checkout -b [JIRA-ID]

   # After implementation, testing, and linting are complete:
   # Stage only the files related to this task
   git add [modified-files]

   # Commit with conventional commit format
   git commit -m "feat([JIRA-ID]): [Brief description of change]"
   # Examples:
   #   git commit -m "feat(CHEF-12345): Handle missing or invalid kubeconfig file gracefully"
   #   git commit -m "fix(CHEF-12345): Correct namespace handling in kubectl client"
   #   git commit -m "docs(CHEF-67890): Update README with new authentication methods"

   # Push branch to origin
   git push origin [JIRA-ID]
   ```

4. **PR Title Selection**: Before creating PR, ask user to select change type:
   ```
   What type of change is this PR?
   1. feat: New feature or functionality
   2. fix: Bug fix
   3. docs: Documentation changes
   4. refactor: Code refactoring without functionality change
   5. test: Adding or updating tests
   6. chore: Maintenance tasks, dependency updates
   7. perf: Performance improvements
   8. style: Code style/formatting changes
   9. ci: CI/CD pipeline changes
   10. revert: Reverting previous changes
   ```

5. **GitHub CLI PR Creation**:
   ```bash
   # Ensure GitHub CLI is authenticated
   gh auth status
   # If not authenticated: gh auth login

   # Set default repository (first time only)
   gh repo set-default inspec/train-kubernetes

   # Create PR with change type and ai-assisted label
   gh pr create --title "{CHANGE_TYPE}: {JIRA_ID} - Brief description" --body-file pr_template.md --label "ai-assisted"
   ```

   Examples:
   - `feat: CHEF-1234 - Add kubeconfig validation and error handling`
   - `fix: CHEF-5678 - Resolve namespace isolation in kubectl client`
   - `docs: CHEF-9999 - Update README with authentication examples`

6. **PR Description Format**: **MUST** follow this exact template format:
   ```markdown
   <!--- Provide a short summary of your changes in the Title above -->

   ## Description
   <!--- Describe your changes in detail, what problems does it solve? -->

   [Your detailed description here]

   This work was completed with AI assistance following Progress AI policies.

   ## Related Issue
   <!--- If you are suggesting a new feature or change, please create an issue first -->
   <!--- Please link to the issue, discourse, or stackoverflow here: -->

   **Jira Ticket:** [CHEF-XXXXX](https://progress-chef.atlassian.net/browse/CHEF-XXXXX)

   ## Changes

   - Enhanced `[file.rb]` with [description]:
     - [Specific change 1]
     - [Specific change 2]
     - [Specific change 3]

   - Added comprehensive RDoc documentation with examples

   - Added [N] test scenarios in `[test_file.rb]`:
     - [Test scenario 1]
     - [Test scenario 2]
     - [Test scenario 3]

   ## Test Results

   - ✅ All [N] tests passing ([X] [module] tests + [Y] other tests)
   - ✅ Code coverage: **[XX.XX]%** (exceeds 80% requirement)
   - ✅ RuboCop: 0 violations in modified files

   ## Types of changes
   <!--- What types of changes does your code introduce? Put an `x` in all the boxes that apply: -->
   - [ ] Bug fix (non-breaking change which fixes an issue)
   - [ ] New content (non-breaking change)
   - [ ] Breaking change (a content change which would break existing functionality or processes)

   ## Checklist:
   <!--- Go over all the following points, and put an `x` in all the boxes that apply. -->
   <!--- If you're unsure about any of these, don't hesitate to ask. We're here to help! -->
   - [ ] I have read the **CONTRIBUTING** document.

   ## Files Changed

   - `[file1.rb]` - [Description of changes]
   - `[file2.rb]` - [Description of changes]
   ```

7. **Execute PR Creation**:
   - Create temporary `pr_template.md` with filled template (including AI assistance statement)
   - Run: `gh pr create --title "{CHANGE_TYPE}: {JIRA_ID} - Brief description" --body-file pr_template.md --label "ai-assisted"`
   - Clean up temporary file
   - **Always use exact template format** - never modify structure

8. **PR Description Best Practices**:
   - Use markdown format (not HTML)
   - Include direct link to Jira ticket
   - List specific changes with bullet points
   - Include test results with actual numbers
   - List all modified files with brief descriptions
   - Use ✅ checkmarks for completed items
   - Include AI assistance statement

9. **Conventional Commit Format**:
   - `feat(JIRA-ID): description` - New features
   - `fix(JIRA-ID): description` - Bug fixes
   - `docs(JIRA-ID): description` - Documentation changes
   - `test(JIRA-ID): description` - Test additions/changes
   - `refactor(JIRA-ID): description` - Code refactoring
   - `chore(JIRA-ID): description` - Maintenance tasks
   - `perf(JIRA-ID): description` - Performance improvements
   - `style(JIRA-ID): description` - Code style/formatting changes
   - `ci(JIRA-ID): description` - CI/CD pipeline changes
   - `revert(JIRA-ID): description` - Reverting previous changes

10. **Required PR Labels**: Always add these labels to PRs:
    - `runtest:all:stable` (for CI/CD testing)
    - `ai-assisted` (to mark AI-assisted work)

**Step Completion**:
```
✅ Phase 6 Complete: PR created successfully
📋 Branch name: [JIRA-ID]
📋 PR number: #[number]
📋 PR URL: [URL]
📋 Labels added: runtest:all:stable, ai-assisted
📝 Next Phase: Update Jira Ticket
❓ Do you want to continue with the next phase?
```

### Phase 7: Update Jira Ticket (Mandatory)

After PR is created, update the Jira ticket:

1. **Update AI Assistance Field**: Use atlassian-mcp-server to mark the work as AI-assisted
   - Use `mcp_atlassian-mcp_editJiraIssue` tool
   - Set custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
   - **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`

2. **Verify Update**: Confirm the field was updated successfully

3. **Add PR Comment to Jira** (Optional):
   - Use the **atlassian-mcp-server** MCP to add a comment to the Jira ticket
   - Include the PR link and summary of changes
   - Mention test coverage and verification status

4. **Comment Format** (if adding comment):
   ```markdown
   ## Pull Request Created

   PR #[number] has been created: [PR URL]

   ### Implementation Summary
   - [Brief description of implementation]
   - [Key changes made]
   - All [N] tests passing with [XX.XX]% code coverage
   - 0 RuboCop violations in modified files

   ### Files Changed
   - `[file1.rb]` - [Description]
   - `[file2.rb]` - [Description]

   This work was completed with AI assistance following Progress AI policies.
   ```

5. **Transition Ticket** (if applicable):
   - Update ticket status to "In Review" or appropriate status
   - Assign to reviewer if needed

**Step Completion**:
```
✅ Phase 7 Complete: Jira ticket updated
📋 AI Assistance field set to "Yes"
📋 Comment added to [JIRA-ID] (if applicable)
📋 PR link included in Jira
📝 Workflow Complete! All phases finished.
```

## Prompt-Based Development Process

### Step-by-Step Execution with Confirmations

All tasks must be **prompt-based** with explicit confirmation at each phase:

1. **After each phase**: Provide a detailed summary of what was accomplished
2. **Before next phase**: Clearly state what the next phase will be
3. **Progress tracking**: Show which phases are complete and which remain
4. **Confirmation required**: Ask "Do you want to continue with the next phase?" before proceeding
5. **Never auto-proceed**: Wait for explicit user confirmation before moving to the next phase

### Workflow Summary Format

Use this format after each phase:
```
✅ Phase [N] Complete: [Phase name]
📋 Summary: [What was accomplished]
📋 Key outcomes: [Bullet points of key results]

📝 Remaining Phases:
   [ ] Phase [N+1]: [Phase name]
   [ ] Phase [N+2]: [Phase name]
   ...

🎯 Next Phase: [Phase name] - [Brief description of what will be done]

❓ Do you want to continue with the next phase?
```

### Example Workflow Execution

```
✅ Phase 1 Complete: Task Analysis & Jira Integration
📋 Summary: Fetched and analyzed Jira ticket CHEF-12345
📋 Key outcomes:
   • Requirement: Handle missing or invalid kubeconfig file gracefully
   • Acceptance criteria: Add error handling with clear user messages
   • Components: connection.rb needs error handling, connection_test.rb needs test cases

📝 Remaining Phases:
   [ ] Phase 2: Implementation Planning
   [ ] Phase 3: Code Implementation
   [ ] Phase 4: Testing Requirements
   [ ] Phase 5: Code Quality & Linting
   [ ] Phase 6: Branch Management & PR Creation
   [ ] Phase 7: Update Jira Ticket

🎯 Next Phase: Implementation Planning - Analyze codebase and create implementation plan

❓ Do you want to continue with the next phase?
```

## MCP Server Integration

### Atlassian MCP Server Usage

**Server Configuration**:
- Server URL: `https://mcp.atlassian.com/v1/sse`
- Server type: `http`
- Configuration file: `.vscode/mcp.json`

> **Note:** The `.vscode/mcp.json` configuration file is not included in the repository by default. You must create this file yourself in the `.vscode` directory of your local repository.
>
> **Example `.vscode/mcp.json` configuration:**
> ```json
> {
>   "serverUrl": "https://mcp.atlassian.com/v1/sse",
>   "serverType": "http",
>   "auth": {
>     "username": "your-username",
>     "apiToken": "your-api-token"
>   }
> }
> ```
>
> Replace `"your-username"` and `"your-api-token"` with your actual Atlassian credentials.

### MCP Server Functions

For Jira interactions, use the following MCP server functions:

- **Get Issue**: `mcp_atlassian-mcp_getJiraIssue` - Fetch issue details
- **Edit Issue**: `mcp_atlassian-mcp_editJiraIssue` - Update issue fields (including AI Assistance field)
- **Search Issues**: `mcp_atlassian-mcp_searchJiraIssuesUsingJql` - Search for related issues
- **Add Comments**: `mcp_atlassian-mcp_addCommentToJiraIssue` - Add progress comments
- **Transition Issue**: `mcp_atlassian-mcp_transitionJiraIssue` - Move issue status

**Critical MCP Usage for AI Assistance**:
```
# Update AI Assistance field (MANDATORY for all AI-assisted work)
mcp_atlassian-mcp_editJiraIssue(
  cloudId: "[YOUR_CLOUD_ID]",
  issueIdOrKey: "CHEF-12345",
  fields: {
    "customfield_11170": {
      "value": "Yes"
    }
  }
)
```

### Working with Jira Tickets

When working with Jira tickets:
1. Use the **atlassian-mcp-server** MCP server for Jira integration
2. Fetch issue details using `mcp_atlassian-mcp_getJiraIssue`
3. Read requirements, acceptance criteria, and comments
4. Parse technical requirements related to Kubernetes resources
5. Update AI Assistance field using `mcp_atlassian-mcp_editJiraIssue` (MANDATORY)
6. Verify AI Assistance field update was successful
7. Optionally add comments to ticket when PR is created using `mcp_atlassian-mcp_addCommentToJiraIssue`
8. Update ticket status as needed using `mcp_atlassian-mcp_transitionJiraIssue`

**Example MCP Usage**:
- Fetch issue: Use MCP to get full Jira issue details
- Read story points: Understand complexity and scope
- Review attachments: Check for any diagrams or specifications
- Check linked issues: Identify dependencies or related work
- Update AI field: Set customfield_11170 to "Yes" for AI-assisted work

## Code Quality Standards

### Ruby Standards
- **Ruby version**: Minimum Ruby 3.1+
- **Frozen strings**: Files use `# frozen_string_literal: true`
- Follow Ruby style guide conventions
- Use meaningful variable and method names
- Keep methods focused and single-purpose
- Add RDoc documentation for public APIs
- Handle exceptions gracefully with specific error types

**String Literal Handling**:
```ruby
# Files start with frozen string literal comment
# frozen_string_literal: true

# Good - create mutable string when needed
out = +""
out << data

# Bad - may cause frozen string errors
out = ""
out << data  # This will fail if string is frozen
```

### Train Plugin Architecture
- **Transport**: Inherit from `Train.plugin(1)` base
- **Connection**: Implement connection to Kubernetes API
- **Platform**: Detect and report Kubernetes platform information
- **File resources**: Support Linux file operations in containers

### Kubernetes-Specific Guidelines
- Support multiple authentication methods (kubeconfig, service account, etc.)
- Handle Kubernetes API versions correctly
- Support namespace isolation
- Implement proper resource cleanup
- Add comprehensive error messages for Kubernetes API failures
- Support label selectors and field selectors
- Handle pagination for large result sets

### Error Handling
```ruby
# Good error handling example
def fetch_resource(api, type, namespace, name)
  begin
    @client.get_resource(api, type, namespace, name)
  rescue K8s::Error::NotFound => e
    raise Train::ResourceNotFound, "Kubernetes resource not found: #{type}/#{name} in namespace #{namespace}"
  rescue K8s::Error::Unauthorized => e
    raise Train::UnauthorizedError, "Unauthorized to access Kubernetes API: #{e.message}"
  rescue StandardError => e
    raise Train::TransportError, "Failed to fetch Kubernetes resource: #{e.message}"
  end
end
```

## Testing Strategy

### Testing Framework

Train-Kubernetes uses **Minitest** as its testing framework with the following setup:

- **Framework**: Minitest (configured in `test/helper.rb`)
- **Mocking**: Mocha for mocking and stubbing
- **Coverage**: SimpleCov for code coverage reporting
- **Style**: Both Minitest spec (`describe`/`it`) and classic class-based (`class ... < Minitest::Test`) styles are acceptable. Examples may use either style.

### Unit Testing with Minitest

- Use Minitest framework (as configured in test/helper.rb)
- Mock Kubernetes API calls using Mocha
- Test individual methods and classes in isolation
- Cover both success and failure scenarios
- Use descriptive test names and assertions

**Key Testing Patterns**:
- Use `require "test/helper"` to load test setup and utilities
- Use `describe` blocks for organizing test groups
- Use `it` blocks for individual test cases
- Use `must_equal`, `must_raise`, etc. for assertions (Minitest expectations)
- Use `mock()` and `stub()` from Mocha for mocking
- Use `expects()` for setting expectations on mocked objects

**Test Structure Example**:
```ruby
require "test/helper"

module TrainPlugins
  module TrainKubernetes
    class ConnectionTest < Minitest::Test
      describe "parse_kubeconfig method" do
        it "raises error when kubeconfig option is missing" do
          conn = Connection.new({})
          err = assert_raises(Train::UserError) do
            conn.parse_kubeconfig
          end
          assert_includes err.message, "No kubeconfig file specified"
        end

        it "raises error when kubeconfig file does not exist" do
          conn = Connection.new({ kubeconfig: "/nonexistent/file" })
          err = assert_raises(Train::UserError) do
            conn.parse_kubeconfig
          end
          assert_includes err.message, "Kubeconfig file not found"
        end

        it "handles YAML syntax errors gracefully" do
          # Test implementation with Tempfile for invalid YAML
        end
      end
    end
  end
end
```

### Test Coverage Requirements
- **Maintain overall coverage > 80%** (CRITICAL)
- Focus on critical paths and error handling
- Include edge cases and boundary conditions
- Test Kubernetes API error scenarios
- Test different kubeconfig formats
- Test resource existence and non-existence

### Mocking Kubernetes API
```ruby
# Example of mocking Kubernetes API calls
def test_fetch_pod_success
  mock_client = mock('kubectl_client')
  mock_client.expects(:get_resource)
             .with('v1', 'pods', 'default', 'test-pod')
             .returns({ 'metadata' => { 'name' => 'test-pod' } })

  connection = TrainPlugins::TrainKubernetes::Connection.new(client: mock_client)
  result = connection.fetch_pod('default', 'test-pod')

  assert_equal 'test-pod', result['metadata']['name']
end
```

### Running Tests Locally
```bash
# Run all unit tests
rake test:unit

# Run specific test file
ruby -I lib:test test/unit/connection_test.rb

# Run with coverage reporting
CI_ENABLE_COVERAGE=1 rake test:unit

# Run RuboCop linting
rake lint
```

## Documentation Requirements

### Code Documentation
- Add RDoc comments for all public methods
- Include parameter descriptions with types
- Document return values and types
- Provide usage examples for complex methods
- Document exceptions that may be raised
- Include examples of Kubernetes resources expected

### README Updates
- Update README.md when adding new features
- Include configuration examples for new functionality
- Add troubleshooting sections for Kubernetes-specific issues
- Maintain accurate API usage examples
- Document required Kubernetes permissions

### Changelog Updates
- Update CHANGELOG.md for all user-facing changes
- Follow existing changelog format
- Include issue/PR references
- Categorize changes (Added, Changed, Fixed, Deprecated, Removed)

## Security Considerations

### Credential Management
- Never log kubeconfig contents
- Sanitize logs to prevent credential exposure
- Support secure credential injection
- Handle service account tokens securely
- Implement proper session cleanup

### Kubernetes Security
- Respect namespace isolation
- Follow RBAC permissions
- Validate resource access before operations
- Implement proper TLS verification
- Support certificate-based authentication

## Complete Workflow Summary

When implementing a task with a Jira ID, follow this complete 7-phase workflow:

### Pre-Implementation
1. ✅ **Phase 1**: Fetch Jira issue using **atlassian-mcp-server** MCP server
2. ✅ **Phase 1**: Read and understand requirements thoroughly
3. ✅ **Phase 1**: Analyze affected components
4. ✅ **Phase 2**: Create implementation plan
5. ✅ Get user confirmation to proceed

### Implementation
6. ✅ **Phase 3**: Create feature branch with Jira ID
7. ✅ **Phase 3**: Implement code changes following standards
8. ✅ **Phase 3**: Add comprehensive RDoc documentation
9. ✅ Get user confirmation to proceed to testing

### Testing
10. ✅ **Phase 4**: Create unit tests with > 80% coverage
11. ✅ **Phase 4**: Mock Kubernetes API calls appropriately
12. ✅ **Phase 4**: Test success and error scenarios
13. ✅ **Phase 4**: Run full test suite and verify passing
14. ✅ Get user confirmation to proceed to quality checks

### Quality Assurance
15. ✅ **Phase 5**: Run RuboCop linting and fix violations
16. ✅ **Phase 5**: Run style checks
17. ✅ **Phase 5**: Verify no prohibited files modified
18. ✅ **Phase 5**: Update CHANGELOG.md if needed
19. ✅ **Phase 5**: Update README.md if needed
20. ✅ Get user confirmation to proceed to PR creation

### PR Creation
21. ✅ **Phase 6**: Commit changes with conventional commit message
22. ✅ **Phase 6**: Push branch to origin
23. ✅ **Phase 6**: Ask user to select change type for PR title
24. ✅ **Phase 6**: Create PR with markdown-formatted description and AI assistance statement
25. ✅ **Phase 6**: Add `runtest:all:stable` and `ai-assisted` labels
26. ✅ Get user confirmation to proceed to Jira update

### Jira Update
27. ✅ **Phase 7**: Update AI Assistance field (customfield_11170) to "Yes" via MCP
28. ✅ **Phase 7**: Verify AI assistance field was updated successfully
29. ✅ **Phase 7**: Add PR comment to Jira ticket via MCP (optional)
30. ✅ **Phase 7**: Include PR link and implementation summary
31. ✅ **Phase 7**: Update ticket status if applicable

### Completion
32. ✅ Provide complete summary of all changes
33. ✅ List all files modified
34. ✅ Report test coverage achieved
35. ✅ Confirm workflow completion

## Final Checklist

Before completing any task, verify:
- [ ] Jira issue fetched and understood (if Jira ID provided)
- [ ] Code follows Ruby 3.1+ conventions and Train plugin patterns
- [ ] Unit tests written and passing (coverage > 80%)
- [ ] All tests use proper mocking for Kubernetes API
- [ ] RuboCop linting passes with no violations
- [ ] Documentation updated (RDoc, README, CHANGELOG as needed)
- [ ] Security considerations addressed (credentials, RBAC)
- [ ] All prohibited files left unmodified (*.codegen.go, built gems, VERSION unless bumping)
- [ ] Changes tested locally with real/mock Kubernetes cluster
- [ ] Branch created with Jira ID as name
- [ ] Commits follow conventional commit format (feat/fix/docs/test/refactor/chore/perf/style/ci/revert)
- [ ] User selected change type for PR title
- [ ] PR created with markdown-formatted description (not HTML)
- [ ] AI assistance statement included in PR description
- [ ] PR labeled with `runtest:all:stable` and `ai-assisted`
- [ ] Jira AI Assistance field (customfield_11170) set to "Yes" via MCP
- [ ] Jira AI Assistance field update verified
- [ ] Jira ticket updated with PR link and summary via MCP (optional)
- [ ] User confirmation received at each phase
- [ ] Complete summary provided after each phase

## Emergency Procedures

If something goes wrong:
1. **Rollback**: Use `git reset` or `git revert` as appropriate
   ```bash
   # Undo last commit (keep changes)
   git reset --soft HEAD~1

   # Discard changes completely
   git reset --hard HEAD
   ```
2. **Clean workspace**: Ensure no temporary files or credentials remain
3. **Stop and report**: Document the issue and ask for guidance
4. **Check test status**: Verify tests still pass after rollback
5. **Review changes**: Use `git diff` to verify what changed
6. **Seek guidance**: Ask for clarification before proceeding

## Common Tasks Reference

### Adding a New Kubernetes Resource Type
1. Update `connection.rb` with new resource methods
2. Update `kubectl_client.rb` if needed
3. Add comprehensive tests
4. Update documentation
5. Ensure > 80% test coverage

### Adding File Operations Support
1. Extend `lib/train-kubernetes/file/linux.rb`
2. Add permission handling if needed
3. Add immutable file checks if applicable
4. Create comprehensive tests in `test/unit/file/`
5. Mock kubectl exec calls appropriately

### Updating Kubernetes Client Dependency
1. Update `train-kubernetes.gemspec`
2. Run `bundle update k8s-ruby`
3. Test compatibility thoroughly
4. Update version constraints if needed
5. Update CHANGELOG.md

---

**Remember**:
- **7-Phase Workflow**: Follow all 7 phases (Analysis → Planning → Implementation → Testing → Linting → PR Creation → Jira Update)
- **Prompt-Based**: Every task is prompt-based with confirmation at each phase
- **Step Summaries**: Always provide detailed summaries and ask before proceeding to next phase
- **Test Coverage**: Maintain test coverage above 80% at all times (CRITICAL)
- **MCP Integration**: Use **atlassian-mcp-server** for Jira integration (fetch issues, update AI field, add comments)
- **AI Assistance Field**: MUST update customfield_11170 to "Yes" for all AI-assisted work
- **Prohibited Files**: Never modify `*.codegen.go` files or built gem artifacts
- **PR Requirements**:
  - Always add `runtest:all:stable` and `ai-assisted` labels to PRs
  - Use markdown format for PR descriptions (not HTML)
  - Include AI assistance statement: "This work was completed with AI assistance following Progress AI policies."
  - Ask user to select change type for PR title (feat/fix/docs/test/refactor/chore/perf/style/ci/revert)
  - Use conventional commit format: `{CHANGE_TYPE}(JIRA-ID): description`
  - Create PR using `gh pr create --title "{CHANGE_TYPE}: {JIRA_ID} - Brief description" --body-file pr_template.md --label "ai-assisted"`
- **Branch Naming**: Use Jira ID as branch name (e.g., `CHEF-12345`)
- **No Auto-Proceed**: Wait for explicit user confirmation before moving to next phase
- **Jira Updates**:
  - MUST update AI Assistance field (customfield_11170) to "Yes" via `mcp_atlassian-mcp_editJiraIssue`
  - Verify field update was successful
  - Optionally add comment with PR link and summary after field update
