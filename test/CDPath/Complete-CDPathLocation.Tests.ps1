using namespace System.Diagnostics.CodeAnalysis
using module '..\..\posh-terminator\src\CDPath.psm1'

# TODO add CDPATH not set
Describe 'CDPath' {
  InModuleScope CDPath {
    Describe 'Complete-CDPathLocation' {
      BeforeEach {
        $testDirectory = Split-Path -Path $PSScriptRoot -Parent
        $repoDirectory = Split-Path -Path $testDirectory -Parent
        $cdPath = ".;$testDirectory;$repoDirectory"
        Mock Get-CDPathVariable { $cdPath }
      }

      Context 'WordToComplete is not found' {
        Context 'Using absolute path branch' {
          BeforeEach {
            $wordToComplete = '~/does-not-exist'
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
              -ParameterName 'Path' `
              -WordToComplete $wordToComplete `
              -CommandAst "Set-CDPathLocation $wordToComplete" `
              -FakeBoundParameters @{ Path = $wordToComplete } `
          }

          It 'returns unaltered WordToComplete' {
            $actual | Should -Be $wordToComplete
          }

          It 'returns one item' {
            $actual | Should -HaveCount 1
          }

          It 'returns string' {
            $actual | Should -BeOfType string
          }
        }

        Context 'Using relative path branch' {
          BeforeEach {
            $wordToComplete = './does-not-exist'
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
              -ParameterName 'Path' `
              -WordToComplete $wordToComplete `
              -CommandAst "Set-CDPathLocation $wordToComplete" `
              -FakeBoundParameters @{ Path = $wordToComplete } `
          }

          It 'returns unaltered WordToComplete' {
            $actual | Should -Be $wordToComplete
          }

          It 'returns one item' {
            $actual | Should -HaveCount 1
          }

          It 'returns string' {
            $actual | Should -BeOfType string
          }
        }

        Context 'Using cdpath branch' {
          BeforeEach {
            $wordToComplete = 'does-not-exist'
            [SuppressMessage('PSReviewUnusedParameter', 'actual')]
            $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
              -ParameterName 'Path' `
              -WordToComplete $wordToComplete `
              -CommandAst "Set-CDPathLocation $wordToComplete" `
              -FakeBoundParameters @{ Path = $wordToComplete } `
          }

          It 'returns unaltered WordToComplete' {
            $actual | Should -Be $wordToComplete
          }

          It 'returns one item' {
            $actual | Should -HaveCount 1
          }

          It 'returns string' {
            $actual | Should -BeOfType string
          }
        }
      }

      Context 'WordToComplete is found' {
        Context 'Once' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures')
          }

          Context 'Using absolute path branch' {
            BeforeEach {
              $wordToComplete = Join-Path -Path $testDirectory -ChildPath 'fix'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
            }

            It 'returns CompletionText' {
              $actual.CompletionText | Should -Be ($expected.FullName | Join-Path -ChildPath '')
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'Using relative path branch' {
            BeforeEach {
              $wordToComplete = './test/fix'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | ForEach-Object {
                    Join-Path -Path '.' -ChildPath 'test' -AdditionalChildPath $_, ''
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'Using cdpath branch' {
            BeforeEach {
              $wordToComplete = 'fix'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
            }

            It 'returns CompletionText' {
              $actual.CompletionText | Should -Be ($expected.Name | Join-Path -ChildPath '')
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'With hidden directories' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item '.git' -Force)
            }

            Context 'Using absolute path branch' {
              BeforeEach {
                $wordToComplete = Join-Path -Path $repoDirectory -ChildPath '.g'
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText | Should -Be ($expected.FullName | Join-Path -ChildPath '')
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using relative path branch' {
              BeforeEach {
                $wordToComplete = './.g'
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '.' -ChildPath $_ -AdditionalChildPath ''
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using cdpath branch' {
              BeforeEach {
                $wordToComplete = '.g'
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText | Should -Be ($expected.Name | Join-Path -ChildPath '')
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }
          }

          Context 'With space' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures/has space')
            }

            Context 'Using absolute path branch' {
              BeforeEach {
                $wordToComplete = Join-Path -Path $testDirectory `
                  -ChildPath 'fixtures' `
                  -AdditionalChildPath 'has sp'
                $wordToComplete = "'$wordToComplete'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object {
                      "'$_'"
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using relative path branch' {
              BeforeEach {
                $wordToComplete = "'./test/fixtures/has sp'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      "'$(Join-Path -Path '.' -ChildPath 'test' -AdditionalChildPath 'fixtures', $_, '')'"
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using cdpath branch' {
              BeforeEach {
                $wordToComplete = "'fixtures/has sp'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      "'$(Join-Path -Path 'fixtures' -ChildPath $_ -AdditionalChildPath '')'"
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }
          }
        }

        Context 'Multiple times' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = @(Get-Item 'test/fixtures/no-space/bar',
              'test/fixtures/no-space/foo',
              'test/fixtures/no-space/foobar')
          }

          Context 'Using absolute path branch' {
            BeforeEach {
              $wordToComplete = Join-Path -Path $testDirectory -ChildPath 'fixtures' `
                -AdditionalChildPath 'no-space', ''
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
            }

            It 'returns CompletionText' {
              $actual.CompletionText | Should -Be ($expected.FullName | Join-Path -ChildPath '')
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'Using relative path branch' {
            BeforeEach {
              $wordToComplete = './test/fixtures/no-space/'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | ForEach-Object {
                    Join-Path -Path '.' -ChildPath 'test' `
                      -AdditionalChildPath 'fixtures', 'no-space', $_, ''
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'Using cdpath branch' {
            BeforeEach {
              $wordToComplete = 'fixtures/no-space/'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
            }

            It 'returns CompletionText' {
              $actual.CompletionText `
                | Should -Be ($expected.Name | ForEach-Object {
                    Join-Path -Path 'fixtures' -ChildPath 'no-space' -AdditionalChildPath $_, ''
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'With quotes' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
            }

            Context 'Using absolute path branch' {
              BeforeEach {
                $wordToComplete = Join-Path -Path $repoDirectory -ChildPath 'posh-terminator' `
                  -AdditionalChildPath 'config', 'win'
                $wordToComplete = "'$wordToComplete'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText | Should -Be ($expected.FullName | Join-Path -ChildPath '')
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using relative path branch' {
              BeforeEach {
                $wordToComplete = "'./posh-terminator/config/win'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using cdpath branch' {
              BeforeEach {
                $wordToComplete = "'posh-terminator/config/win'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }
          }

          Context 'With symlinks' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'home/.posh-terminator/config',
                'home/.posh-terminator/src')
            }

            Context 'Using absolute path branch' {
              BeforeEach {
                $wordToComplete = Join-Path -Path $repoDirectory -ChildPath 'home' `
                  -AdditionalChildPath '.posh-terminator', ''
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText | Should -Be ($expected.FullName | Join-Path -ChildPath '')
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using relative path branch' {
              BeforeEach {
                $wordToComplete = "./home/.posh-terminator/"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      Join-Path -Path '.' -ChildPath 'home' `
                        -AdditionalChildPath '.posh-terminator', $_, ''
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using cdpath branch' {
              BeforeEach {
                $wordToComplete = "home/.posh-terminator/"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }
          }

          Context 'With space' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'test/fixtures/has space/foo',
                'test/fixtures/has space/foobar')
            }

            Context 'Using absolute path branch' {
              BeforeEach {
                $wordToComplete = Join-Path -Path $testDirectory -ChildPath 'fixtures' `
                  -AdditionalChildPath 'has space', 'f'
                $wordToComplete = "'$wordToComplete'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.FullName | Join-Path -ChildPath '' | ForEach-Object {
                      "'$_'"
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using relative path branch' {
              BeforeEach {
                $wordToComplete = "'./test/fixtures/has space/f'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      $directory = Join-Path -Path '.' -ChildPath 'test' `
                        -AdditionalChildPath 'fixtures', 'has space', $_, ''
                      "'$directory'"
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }

            Context 'Using cdpath branch' {
              BeforeEach {
                $wordToComplete = "'fixtures/has space/f'"
                [SuppressMessage('PSReviewUnusedParameter', 'actual')]
                $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                  -ParameterName 'Path' `
                  -WordToComplete $wordToComplete `
                  -CommandAst "Set-CDPathLocation $wordToComplete" `
                  -FakeBoundParameters @{ Path = $wordToComplete } `
              }

              It 'returns CompletionText' {
                $actual.CompletionText `
                  | Should -Be ($expected.Name | ForEach-Object {
                      $directory = Join-Path -Path 'fixtures' -ChildPath 'has space' `
                        -AdditionalChildPath $_, ''
                      "'$directory'"
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

              It 'returns System.Management.Automation.CompletionResult' {
                $actual | Should -BeOfType System.Management.Automation.CompletionResult
              }
            }
          }

          Context 'With leading .\' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator\config\windows-powershell',
                'posh-terminator\config\windows-terminal')
              $wordToComplete = '.\posh-terminator\config\win'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'With leading ../' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator/config/windows-powershell',
                'posh-terminator/config/windows-terminal')
              $wordToComplete = '../posh-terminator/posh-terminator/config/win'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }

          Context 'With leading ..\' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'expected')]
              $expected = @(Get-Item 'posh-terminator\config\windows-powershell',
                'posh-terminator\config\windows-terminal')
              $wordToComplete = '..\posh-terminator\posh-terminator\config\win'
              [SuppressMessage('PSReviewUnusedParameter', 'actual')]
              $actual = Complete-CDPathLocation -CommandName Set-CDPathLocation `
                -ParameterName 'Path' `
                -WordToComplete $wordToComplete `
                -CommandAst "Set-CDPathLocation $wordToComplete" `
                -FakeBoundParameters @{ Path = $wordToComplete } `
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

            It 'returns System.Management.Automation.CompletionResult' {
              $actual | Should -BeOfType System.Management.Automation.CompletionResult
            }
          }
        }
      }
    }
  }
}
