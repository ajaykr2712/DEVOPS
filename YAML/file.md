| ZSH Commands | PowerShell Commmands |
| --- | --- |
| where | where.exe  |
| open | Use Shortcut- Win + R|
| $PATH | $Env:Path |
| ls -a </br> [To see all files[hidden and visible]] | dir -Force |
| vi | vim </br> [need to download] |
| ls -l </br> [To see all files & directories] | Get-ChildItem |
| cat > </br> [To edit] | vim |
| cat file.txt two.txt > total.txt | cat file.txt, two.txt > total.txt |
| cat file.txt \| tr a-z A-Z > upper.txt | (cat 'file.txt').ToUpper() > upper.txt |
| \ </br> [For new line] | ` |
| mkdir random </br> mkdir random/hello </br> [we need to create random first here] | mkdir random/hello </br> [only one line to execute, no need to create random first, it can be created together] |
| touch | [you need to define touch] </br> function touch { </br> Param( </br> [Parameter(Mandatory=$true)] </br> [string]$Path </br> ) </br> if (Test-Path -LiteralPath $Path) { </br> (Get-Item -Path $Path).LastWriteTime = Get-Date </br> } </br> else { </br> New-Item -Type File -Path $Path </br> } </br> } |
| sudo | runas |
| df | gdr |
| du | [need to define du] </br> function du($path=".") { </br> Get-ChildItem $path \| </br> ForEach-Object { </br> $file = $_ </br> Get-ChildItem -File -Recurse $_.FullName \| Measure-Object -Property length -Sum \| </br> Select-Object -Property @{Name="Name";Expression={$file}}, </br> @{Name="Size(MB)";Expression={[math]::round(($_.Sum / 1MB),2)}} # round 2 decimal places </br> } </br>} |


# Strategy for Learning from Kunal Kushwaha Devops  course
...

## Introduction to networking
Networking fundamentals, OSI layer protocols, port forwarding, how the internet works, command line tools, and more.

## Command line tools
Various command line tools, bash scripting, regex, introduction to git, and more.

## Kubernetes
Introduction, architecture, set-up, objects, networking, storage, HA, monitoring, logging, production-ready applications.

## Servers
Introduction to web-servers, Nginx, and more.

## Infrastructure as code
Infrastructure provisioning, Terraform, Pulumi, configuration management, and more.

## Service mesh
Istio, Envoy, Linkerd, and more.

## Working with cloud providers
Learn about cloud providers, design patterns, and more.

## Chaos engineering
The next step in testing.

## Introduction to Linux
Learn about the essentials of working with Linux, including some important commands.

## Docker
Introduction to containers, hands-on demos, concepts, architecture, images, networking, best practices, development profiles, Docker Compose, Docker Swarm.