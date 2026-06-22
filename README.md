# VS Code Copilot Probing

This script is a read-only inspection tool for VS Code Copilot chat history metadata. Its purpose is to tell you how much Copilot chat activity exists and what types of responses occurred, without printing the actual chat contents.

# How to use?

1. Run ```chmod +x copilot_probe.sh``` in the folder where ```copilot_probe.sh``` is located (for example, in the ```PC``` folder or on the ```C:``` drive).

2. Run the following command in the same folder: ```bash copilot_probe.sh```

3. Read the output as follows (an example):

```
## C:\Users\demo_user\AppData\Roaming\Code\User\workspaceStorage
  workspaces with chatSessions:        18
  workspaces with chatEditingSessions: 21   (>0 means agent/edit mode was used — the signal we want)

total session files: 39

### response 'kind' histogram (across all sessions)
# toolInvocationSerialized / textEditGroup / prepareToolInvocation = tool & file-edit signal.
# markdownContent / strings only = prose-only (low signal for scoring).
   2874 inlineReference
   2135 toolInvocationSerialized
   1982 thinking
   1427 prepareToolInvocation
    986 text
    721 textEditGroup
    654 codeblockUri
    603 undoStop
    481 file
    329 reference
    247 mcpServersStarting
    219 todoList
    143 terminal
     67 progressTaskSerialized
     49 agent
     31 input
     24 image
     11 prompt
      7 notebookEditGroup
      6 confirmation
      4 markdownVuln
      3 directory
      2 tool
      2 progressMessage
      1 elicitation
      1 scmHistoryItem
      1 command
      1 ask

Largest session (best fixture candidate — contains real text, redact before sharing):
52134891        C:\Users\demo_user\AppData\Roaming\Code\User\workspaceStorage\a7f3c91e5d8b4a7cb9d4f1e3c5b6a72/chatSessions/9c4d1e2f-7a8b-4c3d-91e2-f6a7b8c9d0e1.json
```
