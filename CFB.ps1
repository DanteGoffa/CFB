$Seperator = "-", "_", " "

$targDir = Get-Location
$temp = [string] ($targDir) + "\*"
$files = $(Get-ChildItem -path $temp -Recurse -Include *.jpg,*.png,*.jpeg,*.gif,*.bmp,*.tif,*.tiff );
$scriptName = $MyInvocation.MyCommand.name

#Get all the directories
#-------------------------------------------------------------------------------------------------
$directories = @()

foreach($file in $files)
{
	$temp = Split-Path -Path $file.FullName
	if($temp -ne $directories[$directories.Count - 1])
	{
		$directories += $temp
		Write-Output $temp
	}	
}

#THE PAGING FIXING PART
#-------------------------------------------------------------------------------------------------
foreach($sub in $directories) {

	Write-Output "---------------------------------------------------"
	Write-Output "NAME-CHECK"
	Write-Output $sub.Name
	Write-Output ""
	
	$files = $(Get-ChildItem -LiteralPath $sub);
	
	$PageCount = [string]( $files.length)
	$FirstPage = $files[0].Name.split('.')
	
	If ( $firstPage[0] -eq '1' -And $PageCount.length -ne 1)
	{
		Write-Output "----> Incorrect naming convention found"
		
		foreach($file in $files) {
	
			#Current strings in the array still include the extension.
			$PageNumber = $file.Name.split('.')[0]

			#If the current number is not equal to the amount of digits of the pagecount, fix it.
			#(page 37 and amount of pages is 155? Rename to 037)
			if($PageNumber.length -lt $PageCount.length)
			{
				#Calculate how many zeroes have to be placed in front of the number.
				$Multiplier = [int]$PageCount.length - [int]$PageNumber.length
				#Finally renaming the page.
				$newFile = (("0" * $Multiplier) + $PageNumber) + $file.Extension
				
				Rename-Item -LiteralPath $file.FullName -NewName $newFile -Verbose
			}
		}
	}
	else
	{            
		#Split the name FURTHER into parts to inspect for the simple "1". Using the seperator variable all the way on top.
		$NameParts = $firstPage[0].split($Seperator)

		#To memorize on which position the page numbering could be found on.
		$Counter = 0

		foreach($NamePart in $NameParts)
		{
		   #Current part of the name that is being looked at.
		   Write-Output $NamePart

		   #If this part of the whole page's name is finally "1".
		   If ( $NamePart -eq '1' -And $PageCount.length -ne 1)
			{
				#Sometimes the book likes announcing the Volume/Chapter first before the page numbering.
				#To avoid screaming FOUND IT at the chapter number being "1". Lets check every, YES every,
				#page their name on that exact position in their name for number "2". If it was a chapter or volume, it is less likely of a number "2" being on that exact position in the name on another page.
				#Why check every page with foreach for the second page? Because remember windows preferring 39 over 1 at sorting?
				#When the archive got sorted at the start, we managed to put page NUMBER ONE as number 1.
				#But page "number 2" will be number "10".
				foreach($file in $files)
				{
					#Split up every page's name for checking the number.
					$EntryName = $file.Name.split('.')[0]
					$EntryParts = $EntryName.split($Seperator)
					
					#At the position at where number "1" was found in the first page name.
					#If there is the number "2" on that same position in another page's name,
					#We can confirm it is the paging numbers and not the chapters.
					if($EntryParts[$Counter] -eq "2")
					{						
						foreach($file in $files)
						{
							$FirstPage = $file.Name.split('.')
							$NameParts = $firstPage[0].split($Seperator)

							#The only difference now is that we are of course comparing the number at a position in the file's name this time.
							if($NameParts[$Counter].length -lt $PageCount.length)
							{
								$Multiplier = [int]$PageCount.length - [int]$NameParts[$Counter].length

								#Just to simplify.
								$Old = $NameParts[$Counter] # = 1
								$New = ("0" * $Multiplier) + $NameParts[$Counter] # = 01, 001, etc

								#We can't just replace the name like the previous renaming method.
								#We had removed the seperators in the name to find the page numbering and it can it could have been any seperator.
								#To maintain the original filenaming with their original seperators.
								
								#This code will count how many name PARTS it had skipped and how many letters they contained.
								$NumberPosition = 0

								#Now go over the nameparts that had been skipped to get to the pagenumber and add their length.
								#Plus the missing seperator that had been removed after the part.
								For ($i=0; $i -le $Counter - 1; $i++) {
									$NumberPosition += $NameParts[$i].length
									$NumberPosition += 1
								}

								#$FullName = $file.FullName
								#The script has to leave out the extension during the renaming process so a different named page wouldn't get it's extension overwritten, in case it's name is shorter than the others.
								#This created an error however and would make the script use the previous pages "newname" to rename the shorter page. (008.jpg -> 007_01.jpg)
								#To cancel this, let's clean up the previous "Newname" by making it exactly the same as the current page's original name.
								$FullName = $file.DirectoryName + "\" + $file.Basename

								#Now we can remove at the character position we just calculated the amount of characters the old numbering occupied it.
								#And on that same exact position add the new number back in.
								$NewFullName = $file.Basename.remove($NumberPosition, $Old.length).insert($NumberPosition,$New) + $file.Extension

								#Rename with the new name and we got the full page name with all of it's seperators.
								Write-Output $file.Basename
								Write-Output $newFullName
								Rename-Item -LiteralPath ($FullName + $file.Extension) $NewFullName -Verbose
							}
						}
							
						#Break the for each code since it will otherwise keep looking further in the pages for page number 2.
						Break
					}
				}
				#THis is here just in case the found "1" in the nameparts was a false alarm and for example the volume number or whatsoever. if page 2 is not found, this will keep the counter going.
				$Counter += 1
			}
		   #There is no incorrect filenaming in this part of the name, check the next one by adding the counter.
		   else
		   {
				$Counter += 1
		   }
		}
	}
}

#THE CONVERTING TO ARCHIVES PART
#-------------------------------------------------------------------------------------------------
foreach($sub in $directories) {

	Write-Output "---------------------------------------------------"
	Write-Output "ARCHIVING"
	Write-Output $sub.Name
	Write-Output ""
	
	$files = $(Get-ChildItem -LiteralPath $sub);
	
	$FilesArray = @()
	
	foreach($file in $files) {
	
		Write-Output $file.FullName
	
		$FilesArray += $file.Fullname
	}
	
	Compress-Archive -LiteralPath $FilesArray -CompressionLevel Optimal -DestinationPath "$sub.zip"
	
	Remove-Item -LiteralPath $sub -Force -Recurse
}

#Instantly convert the archives to CBZ
Get-ChildItem *.zip -Recurse | Rename-Item -NewName { $_.Name -replace '\.zip','.cbz' }

#Waiting for user input so the console can be read after the script has ran.
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
