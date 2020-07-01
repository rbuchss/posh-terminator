using namespace System.Diagnostics.CodeAnalysis
using module '..\..\posh-terminator\src\CDPath.psm1'

Describe 'CDPath' {
  Describe 'Find-Subdirectories' {
    Context 'Path is not found' {
      It 'returns null' {
        Find-Subdirectories -Path 'does-not-exist' `
          | Should -BeNullOrEmpty
        Find-Subdirectories -Path 'does-not-exist' -FullName `
          | Should -BeNullOrEmpty
        'does-not-exist' | Find-Subdirectories `
          | Should -BeNullOrEmpty
      }
    }

    Context 'Path is found' {
      BeforeEach {
        [SuppressMessage('PSReviewUnusedParameter', 'expected')]
        $expected = @(Get-Item 'test')
      }

      Context 'Once' {
        Context '-FullName: $false' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path 'tes'
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.Name | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns one item' {
            $actual | Should -HaveCount 1
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context '-FullName: $true' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path 'tes' -FullName
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.FullName | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns one item' {
            $actual | Should -HaveCount 1
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context 'With hidden directories' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item '.git' -Force)
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path '.g'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path '.g' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }

        Context 'With space' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures/has space')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path 'test/fixtures/ha'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | ForEach-Object {
                    "'$(Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath $_, '')'"
                  })
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path 'test/fixtures/ha' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object { "'$_'" })
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }

        Context 'With multi-Path pipeline' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures/no-space')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = 'test/fixtures/no', 'test/fixtures/does-not-exist' | Find-Subdirectories
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be @((Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'no-space', ''))
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = 'test/fixtures/no', 'test/fixtures/does-not-exist' | Find-Subdirectories -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }

        Context 'With multi-Path input' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures/no-space')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual =  Find-Subdirectories -Path 'test/fixtures/no', 'test/fixtures/does-not-exist'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be @((Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'no-space', ''))
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual =  Find-Subdirectories -Path 'test/fixtures/no', 'test/fixtures/does-not-exist' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }
      }

      Context 'Multiple times' {
        BeforeEach {
          [SuppressMessage('PSReviewUnusedParameter', 'expected')]
          $expected = @(Get-Item 'home', 'posh-terminator') + $expected
        }

        Context '-FullName: $false' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path '[tph]'
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.Name | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns multiple items' {
            $actual | Should -HaveCount 3
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context '-FullName: $true' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path '[tph]' -FullName
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.FullName | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns multiple items' {
            $actual | Should -HaveCount 3
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context 'With nested directories' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'posh-terminator/config', 'posh-terminator/src')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path 'posh-terminator/'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | ForEach-Object {
                    Join-Path -Path 'posh-terminator' -ChildPath $_ -AdditionalChildPath ''
                  })
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns multiple items' {
              $actual | Should -HaveCount 2
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path 'posh-terminator/' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns multiple items' {
              $actual | Should -HaveCount 2
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context 'With quotes' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path "'posh-terminator/config/win'"
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path 'posh-terminator' -ChildPath 'config' -AdditionalChildPath $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path "'posh-terminator/config/win'" -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading ./' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path './posh-terminator/config/win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '.' -ChildPath 'posh-terminator' -AdditionalChildPath 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path './posh-terminator/config/win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading .\' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator\config\windows-powershell',
                'posh-terminator\config\windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path '.\posh-terminator\config\win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '.' -ChildPath 'posh-terminator' -AdditionalChildPath 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path '.\posh-terminator\config\win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading ../' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path '../posh-terminator/posh-terminator/config/win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '..' -ChildPath 'posh-terminator' `
                        -AdditionalChildPath 'posh-terminator', 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path '../posh-terminator/posh-terminator/config/win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading ..\' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator\config\windows-powershell',
                'posh-terminator\config\windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path '..\posh-terminator\posh-terminator\config\win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '..' -ChildPath 'posh-terminator' `
                        -AdditionalChildPath 'posh-terminator', 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path '..\posh-terminator\posh-terminator\config\win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With symlinks' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'home/.posh-terminator/config',
                'home/.posh-terminator/src')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path 'home/.posh-terminator/'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path 'home' -ChildPath '.posh-terminator' `
                        -AdditionalChildPath $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path 'home/.posh-terminator/' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With space' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures/has space/foo',
                'test/fixtures/has space/foobar')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path "'test/fixtures/has space/f'"
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      "'$(Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'has space', $_, '')'"
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path "'test/fixtures/has space/f'" -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object { "'$_'" })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With multi-Path pipeline' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures',
                'test/fixtures/no-space',
                'test/fixtures/has space')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = 'test/fix', 'test/fixtures/no', 'test/fixtures/ha' | Find-Subdirectories
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be @(
                    (Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath ''),
                    (Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'no-space', ''),
                    "'$(Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'has space', '')'"
                  )
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 3
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = 'test/fix', 'test/fixtures/no', 'test/fixtures/ha' | Find-Subdirectories -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object {
                      if ($_ -match '\s') {
                        "'$_'"
                      } else {
                        $_
                      }
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 3
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With multi-Path input' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures',
                'test/fixtures/no-space',
                'test/fixtures/has space')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual =  Find-Subdirectories -Path 'test/fix', 'test/fixtures/no', 'test/fixtures/ha'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be @(
                    (Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath ''),
                    (Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'no-space', ''),
                    "'$(Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'has space', '')'"
                  )
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 3
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual =  Find-Subdirectories -Path 'test/fix', 'test/fixtures/no', 'test/fixtures/ha' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object {
                      if ($_ -match '\s') {
                        "'$_'"
                      } else {
                        $_
                      }
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 3
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }
        }
      }
    }

    Context 'Pattern is not found' {
      It 'returns null' {
        Find-Subdirectories -Path . -Pattern 'does-not-exist' `
          | Should -BeNullOrEmpty
        Find-Subdirectories -Path . -Pattern 'does-not-exist' -FullName `
          | Should -BeNullOrEmpty
        '.' | Find-Subdirectories -Pattern 'does-not-exist' `
          | Should -BeNullOrEmpty
      }
    }

    Context 'Pattern is found' {
      BeforeEach {
        [SuppressMessage('PSReviewUnusedParameter', 'expected')]
        $expected = @(Get-Item 'test')
      }

      Context 'Once' {
        Context '-FullName: $false' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path . -Pattern 'tes'
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.Name | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns one item' {
            $actual | Should -HaveCount 1
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context '-FullName: $true' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path . -Pattern 'tes' -FullName
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.FullName | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns one item' {
            $actual | Should -HaveCount 1
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context 'With hidden directories' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item '.git' -Force)
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path . -Pattern '.g'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path . -Pattern '.g' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }

        Context 'With space' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures/has space')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path . `
                -Pattern 'test/fixtures/ha'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | ForEach-Object {
                    "'$(Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath $_, '')'"
                  })
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path . `
                -Pattern 'test/fixtures/ha' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object { "'$_'" })
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }

        Context 'With multi-Path pipeline' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures/no-space')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = 'test/fixtures', 'test/fixtures/does-not-exist' `
                | Find-Subdirectories -Pattern 'no'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be @((Join-Path -Path 'no-space' -ChildPath ''))
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = 'test/fixtures', 'test/fixtures/does-not-exist' `
                | Find-Subdirectories -Pattern 'no' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }

        Context 'With multi-Path input' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures/no-space')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual =  Find-Subdirectories -Path 'test/fixtures', 'test/fixtures/does-not-exist' `
                -Pattern 'no'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be @((Join-Path -Path 'no-space' -ChildPath ''))
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual =  Find-Subdirectories -Path 'test/fixtures', 'test/fixtures/does-not-exist' `
                -Pattern 'no' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns one item' {
              $actual | Should -HaveCount 1
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }
        }
      }

      Context 'Multiple times' {
        BeforeEach {
          [SuppressMessage('PSReviewUnusedParameter', 'expected')]
          $expected = @(Get-Item 'home', 'posh-terminator') + $expected
        }

        Context '-FullName: $false' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path . -Pattern '[tph]'
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.Name | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns multiple items' {
            $actual | Should -HaveCount 3
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context '-FullName: $true' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Find-Subdirectories -Path . -Pattern '[tph]' -FullName
          }

          It 'returns the matching directory' {
            $actual.FullName | Should -Be $expected.FullName
          }

          It 'returns CompletionText' {
            $actual.CompletionText `
              | Should -Be ($expected.FullName | Join-Path -ChildPath '')
          }

          It 'returns ListItemText' {
            $actual.ListItemText | Should -Be $expected.Name
          }

          It 'returns ToolTip' {
            $actual.ToolTip | Should -Be $expected.FullName
          }

          It 'returns multiple items' {
            $actual | Should -HaveCount 3
          }

          It 'returns System.IO.DirectoryInfo' {
            $actual | Should -BeOfType System.IO.DirectoryInfo
          }
        }

        Context 'With nested directories' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'posh-terminator/config', 'posh-terminator/src')
          }

          Context '-FullName: $false' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path . -Pattern 'posh-terminator/'
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | ForEach-Object {
                    Join-Path -Path 'posh-terminator' -ChildPath $_ -AdditionalChildPath ''
                  })
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns multiple items' {
              $actual | Should -HaveCount 2
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context '-FullName: $true' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Find-Subdirectories -Path . -Pattern 'posh-terminator/' -FullName
            }

            It 'returns the matching directory' {
              $actual.FullName | Should -Be $expected.FullName
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.FullName | Join-Path -ChildPath '')
            }

            It 'returns ListItemText' {
              $actual.ListItemText | Should -Be $expected.Name
            }

            It 'returns ToolTip' {
              $actual.ToolTip | Should -Be $expected.FullName
            }

            It 'returns multiple items' {
              $actual | Should -HaveCount 2
            }

            It 'returns System.IO.DirectoryInfo' {
              $actual | Should -BeOfType System.IO.DirectoryInfo
            }
          }

          Context 'With quotes' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern "'posh-terminator/config/win'"
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path 'posh-terminator' -ChildPath 'config' `
                        -AdditionalChildPath $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern "'posh-terminator/config/win'" -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading ./' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern './posh-terminator/config/win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '.' -ChildPath 'posh-terminator' `
                        -AdditionalChildPath 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern './posh-terminator/config/win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading .\' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator\config\windows-powershell',
                'posh-terminator\config\windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern '.\posh-terminator\config\win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '.' -ChildPath 'posh-terminator' `
                        -AdditionalChildPath 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern '.\posh-terminator\config\win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading ../' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern '../posh-terminator/posh-terminator/config/win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '..' -ChildPath 'posh-terminator' `
                        -AdditionalChildPath 'posh-terminator', 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern '../posh-terminator/posh-terminator/config/win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With leading ..\' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator\config\windows-powershell',
                'posh-terminator\config\windows-terminal')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern '..\posh-terminator\posh-terminator\config\win'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '..' -ChildPath 'posh-terminator' `
                        -AdditionalChildPath 'posh-terminator', 'config', $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern '..\posh-terminator\posh-terminator\config\win' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With symlinks' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'home/.posh-terminator/config',
                'home/.posh-terminator/src')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern 'home/.posh-terminator/'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path 'home' -ChildPath '.posh-terminator' `
                        -AdditionalChildPath $_, ''
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern 'home/.posh-terminator/' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With space' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures/has space/foo',
                'test/fixtures/has space/foobar')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern "'test/fixtures/has space/f'"
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      "'$(Join-Path -Path 'test' -ChildPath 'fixtures' -AdditionalChildPath 'has space', $_, '')'"
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Find-Subdirectories -Path . `
                  -Pattern "'test/fixtures/has space/f'" -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object { "'$_'" })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 2
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With multi-Path pipeline' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures/no-space/foo',
                'test/fixtures/no-space/foobar',
                'test/fixtures/has space/foo',
                'test/fixtures/has space/foobar')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = 'test/fixtures/no-space', 'test/fixtures/has space' `
                  | Find-Subdirectories -Pattern 'fo'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 4
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = 'test/fixtures/no-space', 'test/fixtures/has space' `
                  | Find-Subdirectories -Pattern 'fo' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object {
                      if ($_ -match '\s') {
                        "'$_'"
                      } else {
                        $_
                      }
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 4
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }

          Context 'With multi-Path input' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures/no-space/foo',
                'test/fixtures/no-space/foobar',
                'test/fixtures/has space/foo',
                'test/fixtures/has space/foobar')
            }

            Context '-FullName: $false' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual =  Find-Subdirectories -Path 'test/fixtures/no-space', 'test/fixtures/has space' `
                  -Pattern 'fo'
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | Join-Path -ChildPath '')
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 4
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }

            Context '-FullName: $true' {
              BeforeEach {
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual =  Find-Subdirectories -Path 'test/fixtures/no-space', 'test/fixtures/has space' `
                  -Pattern 'fo' -FullName
              }

              It 'returns the matching directory' {
                $actual.FullName | Should -Be $expected.FullName
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object {
                      if ($_ -match '\s') {
                        "'$_'"
                      } else {
                        $_
                      }
                    })
              }

              It 'returns ListItemText' {
                $actual.ListItemText | Should -Be $expected.Name
              }

              It 'returns ToolTip' {
                $actual.ToolTip | Should -Be $expected.FullName
              }

              It 'returns multiple items' {
                $actual | Should -HaveCount 4
              }

              It 'returns System.IO.DirectoryInfo' {
                $actual | Should -BeOfType System.IO.DirectoryInfo
              }
            }
          }
        }
      }
    }
  }
}
