<#
 The map identifies a path => SourceItem Properties
 The path root is the Source directory
 There are three "top level keys":
 - FileTypes: This identifies which files are considered SourceItems.  Each key represents a file extension and
     its value is the FileTypes property of the object
 - Path: An array of values where each index represents a "level" of subfolder below the root
     Each index can be either a "Field Name" or a hashtable of regular expressions  with Field Name => value.
     Value can be a regex match group
 - Name: A hashtable of regular expressions with Field Name => value.
     Value can be a regex match group
#>

@{
    FileTypes = @{
        '\.ps1$'  = @{
            FileType = 'PowerShell File'
        }
        '\.eps1$' = @{
            FileType = 'Embedded PowerShell'
            Type = 'template'

        }
        '\.psd1$' = @{
            FileType = 'PowerShell Data File'
            Type = 'data'
        }
        '\.psm1$' = @{
            FileType = 'PowerShell Module File'
            Type = 'module'
            Visibility = 'public'
        }
    }

    <#
    An example path (relative to the source directory):
    Path  : Module1/public/Engine/Start-RocketEngine.ps1
    Level : 0       1      2      3
    #>
    Path      = @(
        # Level 0
        'Module',
        # Level 1
        @{
            '^private'   = @{
                Visibility = 'private'
                Type       = 'function'
            }
            '^public'    = @{
                Visibility = 'public'
                Type       = 'function'
            }
            '^enum'      = @{
                Visibility = 'private'
                Type       = 'enum'
            }
            'operations' = @{
                Visibility = 'private'
                Type       = 'operation'
            }
        },
        # Level 2
        @{
            ## TODO: Use the type to determine the properties, where 't' is type and .dir is directory
            ##       and .file is a file
            ##'{t.dir}' = @{
            # does not have a '.' in the word
            '(^[^.]+$)' = @{
                Component = '{1}'
            }
        }
    )
    Name      = @{
        'Configuration\.psd1' = @{
            FileType   = 'Module Configuration'
            Visibility = 'private'
            Type       = 'Settings'
        }
        '(\w+)-(\w+)'         = @{
            Verb = '{1}'
            Noun = '{2}'
        }
        '(.*?)\.task'         = @{
            Visibility = 'public'
            Type       = 'task-file'
            Name       = '{1}'
        }
        '(.*?)\.build'        = @{
            Visibility = 'public'
            Type       = 'build-script'
            Name       = '{1}'
        }
    }

}
