
Exit-BuildJob {
   Invoke-OutputHook 'ExitBuildTask' 'Before'
   foreach ($attribute in $Job.Attributes) {
        $attribute.OnExit()
   }
   Invoke-OutputHook 'ExitBuildTask' 'After'
}
