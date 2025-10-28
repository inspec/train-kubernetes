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
📝 Next Phase: Branch Management & PR Creation
❓ Do you want to continue with the next phase?
```

### Phase 5: Code Quality & Linting

Before creating PR:
1. **Run RuboCop**: Ensure code follows RuboCop rules
   ```bash
   rake lint
   ```
2. **Fix violations**: Address all RuboCop violations
3. **Run style check**: Run style checks
   ```bash
   rake style
   ```

**Step Completion**:
```
✅ Phase 5 Complete: Code quality checks passed
📋 RuboCop violations: [Number - should be 0]
📝 Next Phase: PR Creation
❓ Do you want to continue with the next phase?
```

### Phase 6: Branch Management & PR Creation

When creating a PR:

1. **Branch naming**: Use the Jira ID as the branch name (e.g., `TRAIN-1234`)
2. **Local development**: All tasks performed on local repository

3. **GitHub CLI workflow** (do NOT use ~/.profile for authentication):
   ```bash
   # Authenticate with GitHub CLI (if not already authenticated)
   gh auth status
   # If not authenticated, run: gh auth login

   # Create and switch to feature branch
   git checkout -b [JIRA-ID]

   # Make changes, run tests, fix linting issues

   # Stage all changes
   git add .

   # Commit with descriptive message
   git commit -m "feat([JIRA-ID]): [descriptive commit message]"

   # Push branch to origin
   git push origin [JIRA-ID]

   # Create PR with HTML-formatted description
   gh pr create --title "[JIRA-ID]: [Brief description]" \
                --body-file pr_description.html \
                --base main

   # Add required label
   gh pr edit --add-label "runtest:all:stable"
   ```

4. **PR Description Format** (use HTML tags in `pr_description.html`):
   ```html
   <h2>Summary</h2>
   <p>Brief description of changes made</p>

   <h2>Jira Ticket</h2>
   <p>Resolves: <a href="[JIRA-URL]">[JIRA-ID]</a></p>

   <h2>Changes Made</h2>
   <ul>
     <li><strong>Component/File 1</strong>: Description of change</li>
     <li><strong>Component/File 2</strong>: Description of change</li>
     <li><strong>Tests</strong>: Description of tests added</li>
   </ul>

   <h2>Testing</h2>
   <ul>
     <li>✅ Unit tests added/updated</li>
     <li>✅ All tests passing</li>
     <li>✅ Test coverage maintained > 80% (current: [X]%)</li>
     <li>✅ RuboCop checks passing</li>
   </ul>

   <h2>Kubernetes Compatibility</h2>
   <ul>
     <li>Tested with Kubernetes version: [version]</li>
     <li>Compatible with KUBECONFIG: [Yes/No]</li>
     <li>kubectl version support: [version range]</li>
   </ul>

   <h2>Checklist</h2>
   <ul>
     <li>✅ Code follows Ruby and Train plugin conventions</li>
     <li>✅ Documentation updated (if needed)</li>
     <li>✅ CHANGELOG.md updated (if needed)</li>
     <li>✅ No prohibited files modified</li>
     <li>✅ Backward compatible with Train and InSpec</li>
   </ul>
   ```

5. **Required PR Label**: Always add `runtest:all:stable` label to PRs

**Step Completion**:
```
✅ Phase 6 Complete: PR created successfully
📋 Branch name: [JIRA-ID]
📋 PR number: #[number]
📋 PR URL: [URL]
📋 Label added: runtest:all:stable
📝 Workflow Complete!
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
📋 Summary: Fetched and analyzed Jira ticket TRAIN-K8S-123
📋 Key outcomes:
   • Requirement: Add support for Kubernetes StatefulSet resources
   • Acceptance criteria: Resource must be queryable via InSpec
   • Components: connection.rb, transport.rb need updates

📝 Remaining Phases:
   [ ] Phase 2: Implementation Planning
   [ ] Phase 3: Code Implementation
   [ ] Phase 4: Testing
   [ ] Phase 5: Code Quality & Linting
   [ ] Phase 6: Branch Management & PR Creation

🎯 Next Phase: Implementation Planning - Analyze codebase and create implementation plan

❓ Do you want to continue with the next phase?
```

## MCP Server Integration

### Atlassian MCP Server Usage

**Server Configuration**:
- Server URL: `https://mcp.atlassian.com/v1/sse`
- Server type: `http`
- Configuration file: `.vscode/mcp.json`

When working with Jira tickets:
1. Use the **atlassian-mcp-server** MCP server for Jira integration
2. Fetch issue details using the appropriate MCP tools
3. Read requirements, acceptance criteria, and comments
4. Parse technical requirements related to Kubernetes resources
5. Update ticket status as needed during development
6. Add comments to ticket when PR is created

**Example MCP Usage**:
- Fetch issue: Use MCP to get full Jira issue details
- Read story points: Understand complexity and scope
- Review attachments: Check for any diagrams or specifications
- Check linked issues: Identify dependencies or related work

## Code Quality Standards

### Ruby Standards
- **Ruby version**: Minimum Ruby 3.1+
- Follow Ruby style guide conventions
- Use meaningful variable and method names
- Keep methods focused and single-purpose
- Add RDoc documentation for public APIs
- Handle exceptions gracefully with specific error types

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

### Unit Testing with Minitest
- Use Minitest framework (as configured in test/helper.rb)
- Mock Kubernetes API calls using Mocha
- Test individual methods and classes in isolation
- Cover both success and failure scenarios
- Use descriptive test names and assertions

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

When implementing a task with a Jira ID, follow this complete workflow:

### Pre-Implementation
1. ✅ Fetch Jira issue using **atlassian-mcp-server** MCP server
2. ✅ Read and understand requirements thoroughly
3. ✅ Analyze affected components
4. ✅ Create implementation plan
5. ✅ Get user confirmation to proceed

### Implementation
6. ✅ Create feature branch with Jira ID
7. ✅ Implement code changes following standards
8. ✅ Add comprehensive RDoc documentation
9. ✅ Get user confirmation to proceed to testing

### Testing
10. ✅ Create unit tests with > 80% coverage
11. ✅ Mock Kubernetes API calls appropriately
12. ✅ Test success and error scenarios
13. ✅ Run full test suite and verify passing
14. ✅ Get user confirmation to proceed to quality checks

### Quality Assurance
15. ✅ Run RuboCop linting and fix violations
16. ✅ Run style checks
17. ✅ Verify no prohibited files modified
18. ✅ Update CHANGELOG.md if needed
19. ✅ Update README.md if needed
20. ✅ Get user confirmation to proceed to PR creation

### PR Creation
21. ✅ Commit changes with descriptive message
22. ✅ Push branch to origin
23. ✅ Create PR with HTML-formatted description
24. ✅ Add `runtest:all:stable` label
25. ✅ Provide PR summary to user

### Post-PR
26. ✅ Provide complete summary of all changes
27. ✅ List all files modified
28. ✅ Report test coverage achieved
29. ✅ Confirm workflow completion

## Final Checklist

Before completing any task, verify:
- [ ] Jira issue fetched and understood (if Jira ID provided)
- [ ] Code follows Ruby 3.1+ conventions and Train plugin patterns
- [ ] Unit tests written and passing (coverage > 80%)
- [ ] All tests use proper mocking for Kubernetes API
- [ ] RuboCop linting passes with no violations
- [ ] Documentation updated (RDoc, README, CHANGELOG)
- [ ] Security considerations addressed (credentials, RBAC)
- [ ] All prohibited files left unmodified (*.codegen.go, built gems)
- [ ] Changes tested locally with real/mock Kubernetes cluster
- [ ] Branch created with Jira ID as name
- [ ] Commits follow conventional commit format
- [ ] PR created with HTML-formatted description
- [ ] PR labeled with `runtest:all:stable`
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
- Every task is prompt-based with confirmation at each phase
- Always provide step summaries and ask before proceeding
- Maintain test coverage above 80% at all times
- Use **atlassian-mcp-server** for Jira integration
- Never modify `*.codegen.go` files
- Always add `runtest:all:stable` label to PRs
- Do NOT use ~/.profile for GitHub CLI authentication
