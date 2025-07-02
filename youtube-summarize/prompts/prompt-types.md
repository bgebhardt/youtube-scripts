# Prompt Types

Here is a list of prompt types created or to consider creating.

# YouTube Summarizer Prompt Types

## 1. Ultra-Short Summary
**Purpose:** Quick scan for busy users, social media sharing
**Output:** 1-2 sentences max, focus on core value proposition
**Best for:** News, announcements, product launches

### short.md

This ultra-short prompt is designed to create maximum-impact summaries perfect for:

Quick decision-making on whether to watch
Social media posts and shares
Executive briefings
Mobile notifications
RSS feeds or news aggregators

The key difference is the extreme focus on brevity while maintaining all the essential information someone needs to understand the video's value in seconds.

## 2. Learning & Educational Videos
**Purpose:** Study aid, knowledge retention, course supplementation
**Focus:** 
- Prerequisites and learning objectives
- Step-by-step breakdowns
- Practice exercises or homework mentioned
- Key concepts and definitions
- Timestamps for review sections

## 3. Technical & Programming Videos
**Purpose:** Developer reference, troubleshooting, implementation guides
**Focus:**
- Code snippets and commands
- Software versions and dependencies
- Error messages and solutions
- Configuration steps
- Links to documentation/resources

## 4. Video Game Content
**Purpose:** Gaming strategy, reviews, news
**Focus:**
- Game mechanics and strategies
- Character builds and loadouts
- Patch notes and updates
- Performance tips and tricks
- Spoiler warnings when relevant

## 5. Tabletop RPG & D&D Content
**Purpose:** Campaign prep, rule clarification, homebrew ideas
**Focus:**
- Rule interpretations and mechanics
- Character creation tips
- Campaign hooks and plot ideas
- Homebrew content details
- Book/supplement references

## 6. Product Reviews & Comparisons
**Purpose:** Purchase decisions, feature analysis
**Focus:**
- Pros and cons clearly separated
- Price points and value assessment
- Competitor comparisons
- Recommended use cases
- Deal alerts or discount codes

### review.md

This product review prompt is specifically designed to help potential buyers by:

Quick Verdict gives an immediate recommendation
Clear Pros/Cons structure for easy comparison
Value Assessment addresses the key question: "Is it worth it?"
Best For/Skip If sections help with targeting
Special Offers captures time-sensitive deals
Comparisons section handles multi-product reviews

The format prioritizes purchase-decision factors over general video content, making it perfect for shoppers who want the key insights without watching entire review videos.

## 7. News & Current Events
**Purpose:** Stay informed, fact-checking, context
**Focus:**
- Key facts and timeline
- Multiple perspectives presented
- Source credibility
- Impact and implications
- Related stories or background

## 8. How-To & Tutorial Videos
**Purpose:** Task completion, skill building
**Focus:**
- Required materials/tools
- Difficulty level and time required
- Step-by-step instructions
- Common mistakes to avoid
- Alternative methods mentioned

## 9. Entertainment & Commentary
**Purpose:** Casual viewing decision, highlights
**Focus:**
- Funniest moments or highlights
- Guest appearances
- Controversial takes or hot topics
- Memes or viral moments
- Series context if applicable

## 10. Business & Finance Content
**Purpose:** Investment decisions, market analysis, career advice
**Focus:**
- Key metrics and data points
- Market predictions and trends
- Action items and recommendations
- Risk factors mentioned
- Timeline for predictions/advice

# Tags

These instructions can be added to any of your prompt templates. The tag generation system will help with:
- Content Organization: Easy categorization and filtering of summaries
- Search & Discovery: Users can find relevant content quickly
- Analytics: Track what types of content you're summarizing most
- Social Media: Ready-made hashtags for sharing
- Content Curation: Group similar videos together

The guidelines ensure tags are practical and searchable rather than just descriptive, making them useful for both human readers and automated systems.

# Video Tags Generation Instructions

## Tag Generation Guidelines

After completing your summary, generate 3-10 relevant tags that capture the video's content, purpose, and target audience. Tags should be useful for categorization, search, and content discovery.

### Tag Categories to Consider:
- **Content Type**: #review, #tutorial, #news, #comparison, #guide, #tips, #analysis
- **Industry/Domain**: #gaming, #tech, #business, #education, #cooking, #fitness, #diy
- **Specific Topics**: #rpg, #coding, #investing, #productivity, #travel, #photography
- **Audience Level**: #beginner, #advanced, #intermediate, #expert
- **Format/Style**: #quicktips, #deepdive, #stepbystep, #breakdown, #explained
- **Trending/Timely**: #2025, #trending, #breaking, #update, #latest

### Tag Rules:
- Use lowercase with # prefix
- Keep tags 1-2 words maximum
- Prioritize searchable terms people actually use
- Include both broad and specific tags
- Avoid overly generic tags like #video or #content
- Include brand/product names when relevant (e.g., #nintendo, #iphone, #chatgpt)

### Tag Selection Priority:
1. **Primary topic** (most important subject)
2. **Content type** (review, tutorial, etc.)
3. **Target audience** (who should watch)
4. **Specific products/brands** mentioned
5. **Trending keywords** relevant to the content

## Output Format Addition:

Add this section to the end of any summary:

```
## Tags
#tag1 #tag2 #tag3 #tag4 #tag5 #tag6 #tag7
```

### Examples by Video Type:

**Gaming Review**: #gaming #review #ps5 #xbox #rpg #2025
**Coding Tutorial**: #coding #tutorial #python #beginner #programming #webdev
**Business News**: #business #news #stocks #finance #investing #market
**Cooking Guide**: #cooking #recipe #italian #pasta #quickmeals #homecooking
**Product Comparison**: #review #comparison #tech #smartphone #android #iphone

### Quality Check for Tags:
- [ ] Would someone search for these terms to find this content?
- [ ] Do the tags accurately represent the video's main topics?
- [ ] Are there 3-10 tags total?
- [ ] Mix of broad (#gaming) and specific (#dnd5e) tags included?
- [ ] No redundant or overly similar tags?

## Adding Timestamps

Add this to prompts to add key timestamps

General Addition for All Prompts:
Add this section to your guidelines:

## Timestamp Integration
- Extract timestamps from the transcript for all key points
- Format as **[MM:SS]** at the beginning of each bullet point
- Focus on timestamps for actionable content, major explanations, and important moments
- When exact timestamps aren't available, estimate based on transcript position

Updated Key Takeaways Section:
Replace your current bullet points with:
## Key Takeaways
- **[2:15]** [Your key point with specific timestamp for direct navigation]
- **[5:42]** [Second key point - viewers can jump directly to this moment]
- **[8:30]** [Continue with timestamped insights]

For Your Product Review Prompt:
Update the Pros/Cons sections to:
## Pros
- **[3:45]** [Specific advantage with timestamp to demonstration]
- **[6:20]** [Another strength with example timestamp]

## Cons
- **[9:10]** [Limitation explained with timestamp to relevant discussion]
This transforms your summaries from static text into interactive video navigation tools. Viewers can click through to exactly the moments that matter most to them, making your summaries much more valuable for busy users who want to verify specific points or see demonstrations firsthand.

# Timestamp Integration Instructions

## Timestamp Extraction Guidelines

When creating summaries, extract and include timestamps for key points to enable direct navigation to relevant video sections. This transforms summaries from passive text into interactive viewing guides.

### How to Handle Timestamps

**Transcript Format Recognition:**
- Look for timestamps in formats like: `[00:15]`, `0:15`, `(2:30)`, `2m30s`, or `at 5 minutes`
- Convert all timestamps to `MM:SS` or `H:MM:SS` format for consistency
- When exact timestamps aren't available, use approximate times based on transcript position

**Timestamp Placement Rules:**
- Include timestamps for all major points and key moments
- Prioritize actionable content, important announcements, and key explanations
- Add timestamps to specific examples, demonstrations, or code snippets
- Include timestamps for section transitions and topic changes

### Updated Output Sections

#### For Key Points/Takeaways:
```
## Key Takeaways
- **[2:15]** [First key point with specific timestamp]
- **[5:42]** [Second key point - link directly to relevant moment]  
- **[8:30]** [Continue with timestamped points]
- **[12:05]** [Include timestamps for demos, examples, or important explanations]
```

#### For Technical Content:
```
## Technical Details
- **[3:20]** [Code example or configuration step]
- **[7:45]** [Installation process or setup instructions]
- **[11:15]** [Troubleshooting section or common errors]
```

#### For Tutorials/How-To Content:
```
## Step-by-Step Guide
1. **[1:30]** [First step with timestamp]
2. **[4:15]** [Second step - viewers can jump directly here]
3. **[7:00]** [Continue with all major steps timestamped]
```

#### For Reviews:
```
## Pros
- **[3:45]** [Specific advantage discussed at this time]
- **[6:20]** [Another pro with demonstration timestamp]

## Cons  
- **[9:10]** [Weakness or limitation explained here]
- **[12:30]** [Another con with example timestamp]
```

### Timestamp Quality Guidelines

**Accuracy Priority:**
- Use exact timestamps when available in transcript
- For approximate times, round to nearest 5-15 seconds
- Err on the side of starting slightly before the content begins

**Coverage Goals:**
- Include timestamps for 60-80% of key points
- Prioritize the most valuable or complex explanations
- Don't timestamp every minor detail - focus on jump-worthy content

**Format Consistency:**
- Always use `**[MM:SS]**` format at the start of bullet points
- For videos over 1 hour, use `**[H:MM:SS]**` format
- Keep timestamp format consistent throughout the summary

### Special Timestamp Sections

#### For Long-Form Content:
```
## Chapter Breakdown
- **[0:00]** Introduction and overview
- **[3:15]** Main topic begins  
- **[12:30]** Key demonstration or example
- **[18:45]** Advanced concepts
- **[25:10]** Conclusion and next steps
```

#### For Multi-Topic Videos:
```
## Topic Timestamps
- **[2:10]** Topic 1: [Brief description]
- **[8:30]** Topic 2: [Brief description]  
- **[15:45]** Topic 3: [Brief description]
```

### Implementation Notes

**When Timestamps Aren't Available:**
- Note in summary: "Timestamps not available in transcript"
- Still provide detailed summary but mention limitation
- Consider adding section headers instead of timestamps

**Timestamp Validation:**
- Ensure timestamps make logical sense (increasing order)
- Verify major timestamps align with key content
- Remove any obviously incorrect timestamps

**User Experience:**
- Timestamps should make the video more navigable, not cluttered
- Focus on moments where viewers would want to jump directly
- Balance detail with usability