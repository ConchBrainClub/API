Import-Module ./database.psm1

$Global:PageSize = 8

function MapEndpoint {

    New-PolarisGetRoute -Path "/" -Scriptblock {
        
        $Offset = $($Request.Query["index"] - 1) * $PageSize

        $Results = Get-Recommend -Offset $Offset -Size $PageSize
        $RespBody = "Not found"

        if ($null -ne $Results) {
            $RespBody = $(ConvertTo-Json -InputObject $Results -Compress)
        } else {
            $Response.SetStatusCode(404)
        }

        $Response.Json($RespBody)
    }

    New-PolarisGetRoute -Path "/Search" -Scriptblock {

        $Offset = $($Request.Query["index"] - 1) * $PageSize
        $Keyword = $Request.Query["keyword"]

        $Results = Search-Recommend -Keyword $Keyword -Offset $Offset -Size $PageSize
        $RespBody = "Not found"

        if ($null -ne $Results) {
            $RespBody = $(ConvertTo-Json -InputObject $Results -Compress)
        } else {
            $Response.SetStatusCode(404)
        }

        $Response.Json($RespBody)
    }

    New-PolarisPutRoute -Path "/Add" -Scriptblock {
        $Response.Send($(Add-Recommend));
    }

    New-PolarisDeleteRoute -Path "/Remove" -Scriptblock {
        $Id = $Request.Query["id"]

        $Results = Remove-Recommend -Id $Id
        $RespBody = "Not found"

        if ($null -ne $Results) {
            $RespBody = $(ConvertTo-Json -InputObject $Results -Compress)
        } else {
            $Response.SetStatusCode(404)
        }

        $Response.Json($RespBody)
    }

    New-PolarisPostRoute -Path "/Edit" -Scriptblock {
        $Response.Send($(Edit-Recommend));
    }
}

function MapStaticFile {
    param (
        $RoutePath,
        $Path
    )

    if ($null -ne $RoutePath -and $null -ne $Path) {
        New-PolarisStaticRoute -RoutePath $RoutePath -Path $Path
    }
}