<# This script creates a left rotation operation on an array of size n. It shifts each of the array's elements unit to the left.
 For example, if left rotations are performed on array [1, 2, 3, 4, 5] , then the array would become [3, 4, 5, 1, 2].
 #>
 
# Definition of the variable $arraysize . We consider $arraysize >= 1  
 $arraysize = 10

# Definition of the pace of left shift $paceofshift. We consider $paceofshift >= 0
 $paceofshift = 2

# Definition of array of size $arraysize
 $array = 1..$arraysize

# Definition of a clone of our $array
  $clonedarray = $array.Clone()

# Here we perform the shifting
foreach ($i in 0..($arraysize-1)){ 

    if(($i+$paceofshift) -le ($arraysize-1)) {
   
        $array[$i] = $clonedarray[$i+$paceofshift]

     }else {
   $array[$i] = $clonedarray[$i+$paceofshift-$arraysize]
     }

}

# Displaying the results:
#
###################################
###################################
Write-Output " Shifting pace : $paceofshift "
Write-Output " Array before shifting: `n $($clonedarray -join " ") "
Write-Output " Array After shifting: `n $($array -join " ") "
##################################
###################################
#

