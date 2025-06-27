<#
    The map identifies a path => SourceItem Properties
    The path root is the Source directory
    There are three "top level keys":
    - FileTypes: This identifies which files are considered SourceItems.  Each key represents a file extension and
        its value is the FileTypes property of the object
    - Path: An array of values where each index represents a "level" of subfolder below the root
        Each index can be either a "Field Name" or a hashtable of regular expressions  with Field Name => value.
        Value can be a regex match group
    - Name: A hashtable of regular expressions  with Field Name => value.
        Value can be a regex match group

    #>

@{
    FileTypes = @{
        '.ps1' = 'PowerShell'
        '.eps1' = 'Embedded PowerShell'
        '.psd1' = 'PowerShell Data File'
        '.psm1' = 'PowerShell Module File'
    }
    Path = @(
        # Level 0
        'Module',
        # Level 1
        @{
            '^private' = @{
                Visibility = 'private'
                Type = 'function'
            }
            '^public' = @{
                Visibility = 'public'
                Type = 'function'
            }
            '^enum' = @{
                Visibility = 'private'
                Type = 'enum'
            }
        }
        'Component'
    )
    Name = @{
        '(\w+)-(\w+)' = @{
            Verb = 'Matches.1'
            Noun = 'Matches.2'
        }
        '(.*?)\.task' = @{
            Visibility = 'public'
            Type = 'task-file'
            Name = 'Matches.1'
        }
        '(.*?)\.build' = @{
            Visibility = 'public'
            Type = 'build-script'
            Name = 'Matches.1'
        }
    }

}
