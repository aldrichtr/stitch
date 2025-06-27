@{
    <# Paths that should not be deleted when `Clean` is run.  By default everything in`$Staging` and `$Artifact` are removed #>
    ExcludePathFromClean = @(
        'C:\Users\TAldrich\projects\github\stitch\out\logs*'
        'C:\Users\TAldrich\projects\github\stitch\out\backup*'
        'C:\Users\TAldrich\projects\github\stitch\out\module*'
    )
}