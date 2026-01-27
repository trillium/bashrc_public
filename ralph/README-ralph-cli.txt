# Ralph CLI Setup

To use the `ralph` command from anywhere in your terminal, add the following to your ~/.zshrc:

    export PATH="$PATH:/Users/trilliumsmith/bashrc_dir/ralph"

Or, if you want to only add the bin directory (for direct access to subcommands):

    export PATH="$PATH:/Users/trilliumsmith/bashrc_dir/ralph/bin"

After updating your .zshrc, reload it with:

    source ~/.zshrc

You can now run:

    ralph find-next
    ralph get-details <story-id>
    ralph mark-complete <story-id>

# Marking a Story Complete

To mark a story as complete:

    ralph mark-complete story-18

This will set `passes=true` for that story in prd.json.
