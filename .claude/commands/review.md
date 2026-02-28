# /review

Code review from Vanilla Rails philosophy perspective.

## Usage

```
/review                    # Review uncommitted changes
/review [file_path]        # Review specific file
/review --staged           # Review staged changes
/review --branch main      # Review changes vs branch
```

## Process

1. **Identify changed files** using `git diff` (or provided paths)
2. **Read each changed file** in full to understand context
3. **Detect over-engineering patterns**
   - Check for unnecessary service objects
   - Look for anemic models
   - Identify business logic in wrong places
4. **Evaluate controller thickness**
   - Controllers should be thin (5-10 lines max per action)
   - Should only parse params and call models
5. **Assess model richness**
   - Models should contain business logic
   - Look for intention-revealing APIs
6. **Generate review report** with prioritized suggestions

## Review Checklist

### Over-Engineering (Critical)
- [ ] No service objects for simple CRUD operations
- [ ] No business logic in services that belongs in models
- [ ] No unnecessary abstraction layers
- [ ] No "Manager" or "Handler" proxies

### Controller Health (Warning)
- [ ] Controllers are thin (< 10 lines per action)
- [ ] Controllers only handle HTTP concerns
- [ ] Controllers call rich model methods directly
- [ ] No business logic in controllers

### Model Health (Warning)
- [ ] Models contain business logic
- [ ] Models have intention-revealing APIs
- [ ] No anemic models (only attributes/associations)
- [ ] Proper use of concerns when needed

### Style (Suggestion)
- [ ] Proper conditional formatting (expanded over guards)
- [ ] Method ordering (class -> public -> private)
- [ ] Proper CRUD resource design
- [ ] Correct visibility modifier formatting

## Red Flags

**Critical: Unnecessary Service Layer**
- Service for simple CRUD that should be in controller
- Service containing domain logic that belongs in model
- Service that's just a thin wrapper around one model method

**Critical: Anemic Model**
- Model with only attributes and associations
- All business logic extracted to services
- Missing intention-revealing APIs

**Warning: Fat Controller**
- Controller with business logic
- Controller coordinating multiple services
- Controller doing data transformation

**Warning: Service Explosion**
- Service for every controller action
- Services sharing logic that should be in models
- No clear justification for service layer

## Output Format

Structure your review as follows:

```markdown
## Vanilla Rails Review

### Files Reviewed
- [List files with layer context]

### Issues Found

🔴 **Critical: [Issue Type]**
Location: `file:line`
[Show problematic code snippet]
**Problem:** [Why this is an issue]
**Fix:** [How to simplify, with code example]

⚠️ **Warning: [Issue Type]**
Location: `file:line`
**Problem:** [What's wrong]
**Recommendation:** [How to improve]

💡 **Suggestion: [Issue Type]**
Location: `file:line`
**Problem:** [Style issue]
**Recommendation:** [Preferred approach]

### Summary

**Good:**
- [Positive observations]

**Needs Attention:**
1. 🔴 [Critical items first]
2. ⚠️ [Warnings next]
3. 💡 [Suggestions last]

**Priority:** [Brief prioritization guidance]
```

## Severity Levels

### 🔴 Critical
Must fix before merge:
- Unnecessary service layer for simple operations
- Business logic in services that belongs in models
- Anemic models with all logic extracted

### ⚠️ Warning
Should fix or acknowledge:
- Fat controllers with business logic
- Service explosion without justification
- Missing intention-revealing model APIs

### 💡 Suggestion
Consider for improvement:
- Style preferences (conditionals, formatting)
- Code organization opportunities
- Pattern simplifications

## Automation Level

This command runs with mid-to-high automation:

1. **Automatic:** File identification, over-engineering detection
2. **Automatic:** Controller thickness analysis
3. **Automatic:** Model health assessment
4. **Automatic:** Issue categorization and prioritization
5. **Manual input needed:** Only for complex architectural decisions
