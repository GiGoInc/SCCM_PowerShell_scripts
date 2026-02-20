$computer = '37QJG12'
#>

$computer = '37QJG12'

# Get-WmiObject -Namespace 'root\ccm\SoftMgmtAgent' -Impersonation 3 -ComputerName $computer -Query 'SELECT ContentID,Location FROM CacheInfoEx WHERE PersistInCache = 1'
$A = Get-WmiObject -Namespace 'root\ccm\SoftMgmtAgent' -Query 'SELECT ContentID,Location FROM CacheInfoEx WHERE PersistInCache = 1'

foreach ($item in $A)
{
    $CID = $item.ContentId
    $loc = $item.location
    Write-Host "$CID`t$loc"
}

<#
Get-WmiObject -Namespace 'root\ccm\SoftMgmtAgent' -Impersonation 3 -ComputerName $computer -Query 'SELECT ContentID,Location FROM CacheInfoEx WHERE PersistInCache = 0'
Query for PersistentCache=0 found folders: 1 to E
Query for PersistentCache=1 found No folder


37QJG12
Directory of Y:\Windows\ccmcache

04/28/2016  06:39 PM    <DIR>          .
04/28/2016  06:39 PM    <DIR>          ..
04/02/2016  02:44 PM    <DIR>          1
04/15/2016  04:17 AM    <DIR>          2
04/15/2016  04:19 AM    <DIR>          3
04/15/2016  04:20 AM    <DIR>          4
04/15/2016  04:21 AM    <DIR>          5
04/15/2016  04:21 AM    <DIR>          6
04/15/2016  04:21 AM    <DIR>          7
04/15/2016  04:21 AM    <DIR>          8
04/15/2016  04:24 AM    <DIR>          9
04/15/2016  04:24 AM    <DIR>          a
04/15/2016  04:24 AM    <DIR>          b
04/15/2016  04:24 AM    <DIR>          c
04/15/2016  04:24 AM    <DIR>          d
04/16/2016  12:34 PM    <DIR>          e

08/15/2015  04:35 AM    <DIR>          3x
08/15/2015  04:50 AM    <DIR>          3y
08/15/2015  04:51 AM    <DIR>          3z
08/15/2015  04:43 AM    <DIR>          4j
08/15/2015  04:48 AM    <DIR>          4k
08/15/2015  04:48 AM    <DIR>          4l
08/15/2015  04:50 AM    <DIR>          4m
08/15/2015  04:50 AM    <DIR>          4n
08/15/2015  04:50 AM    <DIR>          4o
08/15/2015  04:50 AM    <DIR>          4p
08/22/2015  01:55 AM    <DIR>          4q
08/25/2015  02:58 PM    <DIR>          4r
08/31/2015  10:14 AM    <DIR>          4s
09/01/2015  10:16 PM    <DIR>          4t
09/15/2015  02:36 AM    <DIR>          4u
09/15/2015  02:37 AM    <DIR>          4v
09/15/2015  02:37 AM    <DIR>          4w
09/15/2015  02:38 AM    <DIR>          4x
09/15/2015  02:38 AM    <DIR>          4y
09/15/2015  02:38 AM    <DIR>          4z
09/15/2015  02:39 AM    <DIR>          50
09/15/2015  02:39 AM    <DIR>          51
09/15/2015  02:39 AM    <DIR>          52
09/15/2015  02:39 AM    <DIR>          53
09/15/2015  02:39 AM    <DIR>          54
09/15/2015  02:39 AM    <DIR>          55
09/15/2015  02:40 AM    <DIR>          56
09/15/2015  03:35 AM    <DIR>          57
09/18/2015  05:51 PM    <DIR>          58
09/28/2015  04:39 AM    <DIR>          59
09/28/2015  04:39 AM    <DIR>          5a
09/28/2015  04:40 AM    <DIR>          5b
09/28/2015  04:40 AM    <DIR>          5c
09/28/2015  04:40 AM    <DIR>          5d
10/14/2015  09:15 PM    <DIR>          5e
10/15/2015  03:09 AM    <DIR>          5f
10/15/2015  03:09 AM    <DIR>          5g
10/15/2015  03:09 AM    <DIR>          5h
10/15/2015  03:10 AM    <DIR>          5i
10/15/2015  03:10 AM    <DIR>          5j
10/15/2015  03:10 AM    <DIR>          5k
10/15/2015  03:12 AM    <DIR>          5l
10/15/2015  03:12 AM    <DIR>          5m
10/15/2015  03:12 AM    <DIR>          5n
10/15/2015  03:12 AM    <DIR>          5o
10/19/2015  04:09 AM    <DIR>          5p
10/19/2015  04:08 AM    <DIR>          5q
10/19/2015  04:09 AM    <DIR>          5r
10/19/2015  06:23 PM    <DIR>          5s
10/27/2015  11:30 AM    <DIR>          5t
10/28/2015  06:09 PM    <DIR>          5u
10/29/2015  09:52 PM    <DIR>          5v
10/30/2015  09:37 PM    <DIR>          5w
11/04/2015  06:00 PM    <DIR>          5x
11/09/2015  05:53 AM    <DIR>          5y
11/15/2015  05:54 AM    <DIR>          5z
11/15/2015  05:56 AM    <DIR>          60
11/15/2015  07:20 AM    <DIR>          61
11/15/2015  07:11 AM    <DIR>          62
11/15/2015  07:16 AM    <DIR>          63
11/15/2015  07:14 AM    <DIR>          64
11/15/2015  07:19 AM    <DIR>          65
11/15/2015  07:24 AM    <DIR>          66
11/15/2015  07:20 AM    <DIR>          67
11/15/2015  07:22 AM    <DIR>          68
11/15/2015  07:21 AM    <DIR>          69
11/15/2015  07:19 AM    <DIR>          6a
11/15/2015  07:12 AM    <DIR>          6b
11/15/2015  07:13 AM    <DIR>          6c
11/15/2015  07:21 AM    <DIR>          6d
11/15/2015  07:22 AM    <DIR>          6e
11/15/2015  07:21 AM    <DIR>          6f
11/15/2015  06:49 AM    <DIR>          6g
11/15/2015  07:19 AM    <DIR>          6h
11/15/2015  07:19 AM    <DIR>          6i
11/15/2015  07:06 AM    <DIR>          6j
11/15/2015  07:22 AM    <DIR>          6k
11/15/2015  07:20 AM    <DIR>          6l
11/15/2015  07:19 AM    <DIR>          6m
11/15/2015  07:01 AM    <DIR>          6n
11/15/2015  07:15 AM    <DIR>          6o
11/15/2015  07:02 AM    <DIR>          6p
11/15/2015  07:20 AM    <DIR>          6q
11/15/2015  07:19 AM    <DIR>          6r
11/15/2015  07:08 AM    <DIR>          6s
11/15/2015  07:10 AM    <DIR>          6t
11/15/2015  07:04 AM    <DIR>          6u
11/15/2015  06:49 AM    <DIR>          6v
12/14/2015  05:56 AM    <DIR>          6w
12/14/2015  05:56 AM    <DIR>          6x
12/15/2015  06:59 AM    <DIR>          6y
12/15/2015  07:29 AM    <DIR>          6z
12/15/2015  07:32 AM    <DIR>          70
12/15/2015  07:31 AM    <DIR>          71
12/15/2015  07:32 AM    <DIR>          72
12/15/2015  07:32 AM    <DIR>          73
12/15/2015  07:27 AM    <DIR>          74
12/15/2015  07:29 AM    <DIR>          75
12/15/2015  07:32 AM    <DIR>          76
12/15/2015  07:32 AM    <DIR>          77
12/15/2015  07:32 AM    <DIR>          78
12/15/2015  07:27 AM    <DIR>          79
12/15/2015  07:26 AM    <DIR>          7a
12/15/2015  07:26 AM    <DIR>          7b
12/15/2015  07:31 AM    <DIR>          7c
12/18/2015  12:40 PM    <DIR>          7d
12/21/2015  05:29 AM    <DIR>          7e
12/22/2015  05:18 AM    <DIR>          7f
01/04/2016  05:56 AM    <DIR>          7g
01/04/2016  05:56 AM    <DIR>          7h
01/11/2016  05:26 AM    <DIR>          7i
01/15/2016  08:25 AM    <DIR>          7j
01/15/2016  08:27 AM    <DIR>          7k
01/15/2016  08:27 AM    <DIR>          7l
01/15/2016  08:40 AM    <DIR>          7m
01/15/2016  08:36 AM    <DIR>          7n
01/15/2016  08:37 AM    <DIR>          7o
01/15/2016  08:36 AM    <DIR>          7p
01/15/2016  08:27 AM    <DIR>          7q
01/15/2016  08:37 AM    <DIR>          7r
01/15/2016  08:40 AM    <DIR>          7s
01/15/2016  08:37 AM    <DIR>          7t
01/15/2016  08:34 AM    <DIR>          7u
01/15/2016  08:36 AM    <DIR>          7v
01/15/2016  08:25 AM    <DIR>          7w
01/15/2016  08:34 AM    <DIR>          7x
01/15/2016  08:32 AM    <DIR>          7y
01/15/2016  08:25 AM    <DIR>          7z
01/15/2016  08:27 AM    <DIR>          80
01/15/2016  08:37 AM    <DIR>          81
01/15/2016  08:27 AM    <DIR>          82
01/15/2016  08:38 AM    <DIR>          83
01/25/2016  05:49 AM    <DIR>          84
01/25/2016  05:49 AM    <DIR>          85
01/26/2016  06:01 PM    <DIR>          86
01/28/2016  09:49 PM    <DIR>          87
02/15/2016  05:36 AM    <DIR>          88
02/15/2016  05:38 AM    <DIR>          89
02/15/2016  05:40 AM    <DIR>          8a
02/15/2016  05:43 AM    <DIR>          8b
02/15/2016  05:44 AM    <DIR>          8c
02/15/2016  05:46 AM    <DIR>          8d
02/15/2016  05:48 AM    <DIR>          8e
02/15/2016  05:48 AM    <DIR>          8f
02/15/2016  05:49 AM    <DIR>          8g
02/15/2016  05:52 AM    <DIR>          8h
02/15/2016  05:52 AM    <DIR>          8i
02/15/2016  05:52 AM    <DIR>          8j
02/15/2016  05:52 AM    <DIR>          8k
02/15/2016  05:53 AM    <DIR>          8l
02/15/2016  05:53 AM    <DIR>          8m
02/15/2016  05:53 AM    <DIR>          8n
02/15/2016  05:53 AM    <DIR>          8o
03/14/2016  04:13 AM    <DIR>          8p
03/14/2016  04:14 AM    <DIR>          8q
03/14/2016  04:14 AM    <DIR>          8r
03/15/2016  03:15 AM    <DIR>          8s
03/15/2016  03:15 AM    <DIR>          8t
03/15/2016  03:15 AM    <DIR>          8u
03/15/2016  03:17 AM    <DIR>          8v
03/15/2016  03:17 AM    <DIR>          8w
03/15/2016  03:18 AM    <DIR>          8x
03/15/2016  03:18 AM    <DIR>          8y
03/15/2016  03:18 AM    <DIR>          8z
03/15/2016  03:18 AM    <DIR>          90
03/15/2016  03:18 AM    <DIR>          91
03/15/2016  03:18 AM    <DIR>          92
03/15/2016  03:18 AM    <DIR>          93
03/15/2016  03:18 AM    <DIR>          94
03/15/2016  03:19 AM    <DIR>          95
03/15/2016  03:19 AM    <DIR>          96
03/15/2016  03:19 AM    <DIR>          97
               1 File(s)              0 bytes
             188 Dir(s)  127,793,872,896 bytes free


#>
