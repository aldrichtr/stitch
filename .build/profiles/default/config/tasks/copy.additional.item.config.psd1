@{
    <# Additional paths in the `$Source` directory that should be copied to `$Staging`
Each key of this hashtable is a module name of your project whose value is a hashtable of Source = Staging paths
Specify paths relative to your module's source directory on the left and one of three options on the right:
- a path relative to your module's staging directory
- $true to use the same relative path
- $false to skip
Like
@{
    Module1 = @{
        data/configuration.data.psd1 = resources/config.psd1
    }
}
This will copy <source>/Module1/data/configuration.data.psd1 to <staging>/Module1/resources/config.psd1 #>
    CopyAdditionalItems = @{}

    
}