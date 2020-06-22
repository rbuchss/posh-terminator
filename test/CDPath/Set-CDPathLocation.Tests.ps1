using namespace System.Diagnostics.CodeAnalysis
using module '..\..\posh-terminator\src\CDPath.psm1'

Describe 'CDPath' {
  InModuleScope CDPath {
    Describe 'Set-CDPathLocation' {
      BeforeEach {
        $testDirectory = Split-Path -Path $PSScriptRoot -Parent
        $repoDirectory = Split-Path -Path $testDirectory -Parent
        $cdPath = ".;$testDirectory;$repoDirectory"
        Mock Get-CDPathVariable { $cdPath }
      }

      Context 'Directory is not found' {
        Context 'Using -' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '-'
          }

          It 'throws an error' {
            # Unwinds Set-Location stack
            {
              $index = 0
              while ($true) {
                Set-CDPathLocation -Path $directory `
                  -ErrorAction SilentlyContinue -ErrorVariable locationError

                if ($locationError) { throw $locationError }
                if ($index -gt 100) { break }

                $index++
              }
            } | Should -Throw 'There is no location history left to navigate backwards'
          }

          It 'has failed exit status' {
            # Unwinds Set-Location stack
            $index = 0
            while ($true) {
              Set-CDPathLocation -Path $directory `
                -ErrorAction SilentlyContinue -ErrorVariable locationError

              $exitStatus = $?

              if ($locationError -or $index -gt 100) {
                break
              }

              $index++
            }
            $exitStatus | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using +' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '+'
          }

          It 'throws an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Throw 'There is no location history left to navigate forwards'
          }

          It 'has failed exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'CDPATH is not set' {
          BeforeEach {
            Mock Get-CDPathVariable { }
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = 'does-not-exist'
          }

          It 'throws an error' {
            Resolve-Path $directory -ErrorAction SilentlyContinue `
              -ErrorVariable resolveError

            $errorMessage = "Cannot find path '{0}' because it does not exist" -f `
              $resolveError[0].TargetObject

            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Throw $errorMessage
          }

          It 'has failed exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using absolute path' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '~/does-not-exist'
          }

          It 'throws an error' {
            Resolve-Path $directory -ErrorAction SilentlyContinue `
              -ErrorVariable resolveError

            $errorMessage = "Cannot find path '{0}' because it does not exist" -f `
              $resolveError[0].TargetObject

            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Throw $errorMessage
          }

          It 'has failed exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using relative path' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = './does-not-exist'
          }

          It 'throws an error' {
            Resolve-Path $directory -ErrorAction SilentlyContinue `
              -ErrorVariable resolveError

            $errorMessage = "Cannot find path '{0}' because it does not exist" -f `
              $resolveError[0].TargetObject

            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Throw $errorMessage
          }

          It 'has failed exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using cdpath' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = 'does-not-exist'
          }

          It 'throws an error' {
            Resolve-Path $directory -ErrorAction SilentlyContinue `
              -ErrorVariable resolveError

            $errorMessage = "Cannot find path '{0}' because it does not exist" -f `
              $resolveError[0].TargetObject

            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Throw $errorMessage
          }

          It 'has failed exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using pipeline' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = 'does-not-exist'
          }

          It 'throws an error' {
            Resolve-Path $directory -ErrorAction SilentlyContinue `
              -ErrorVariable resolveError

            $errorMessage = "Cannot find path '{0}' because it does not exist" -f `
              $resolveError[0].TargetObject

            {
              $directory | Set-CDPathLocation -ErrorAction Stop
            } | Should -Throw $errorMessage
          }

          It 'has failed exit status' {
            $directory | Set-CDPathLocation -ErrorAction Ignore
            $? | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using pipeline property name' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = New-Object -TypeName PSObject `
              -Property @{ Path = 'does-not-exist' }
          }

          It 'throws an error' {
            Resolve-Path $directory.Path -ErrorAction SilentlyContinue `
              -ErrorVariable resolveError

            $errorMessage = "Cannot find path '{0}' because it does not exist" -f `
              $resolveError[0].TargetObject

            {
              $directory | Set-CDPathLocation -ErrorAction Stop
            } | Should -Throw $errorMessage
          }

          It 'has failed exit status' {
            $directory | Set-CDPathLocation -ErrorAction Ignore
            $? | Should -BeFalse
          }

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }
      }

      Context 'Directory is found' {
        Context '-Path is null' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item -Path $HOME
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = $null
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context "-Path is ''" {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item -Path $HOME
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = ''
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using -' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item -Path $testDirectory
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '-'
            Set-Location -Path $testDirectory
            Set-Location -Path $HOME
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $HOME
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using +' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item -Path $testDirectory
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '+'
            Set-Location -Path $testDirectory
            Set-Location -Path '-'
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'CDPATH is not set' {
          BeforeEach {
            Mock Get-CDPathVariable { }
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item -Path $HOME
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = $HOME
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using absolute path' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'test/fixtures'
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = Join-Path -Path $testDirectory -ChildPath 'fixtures'
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using relative path' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'test/fixtures'
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = './test/fixtures'
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using cdpath' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'test/fixtures'
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = 'fixtures'
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'With hidden directories' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item '.git' -Force
          }

          Context 'Using absolute path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = Join-Path -Path $repoDirectory -ChildPath '.git'
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using relative path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = './.git'
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using cdpath' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = '.git'
              Set-Location -Path $HOME
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $HOME
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }
        }

        Context 'With space' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'test/fixtures/has space'
          }

          Context 'Using absolute path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = Join-Path -Path $testDirectory `
                -ChildPath 'fixtures' `
                -AdditionalChildPath 'has space'
              $directory = "'$directory'"
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using relative path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = "'./test/fixtures/has space'"
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using cdpath' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = "'fixtures/has space'"
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }
        }

        Context 'With quotes' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'posh-terminator/config/windows-powershell'
          }

          Context 'Using absolute path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = Join-Path -Path $repoDirectory -ChildPath 'posh-terminator' `
                -AdditionalChildPath 'config', 'windows-powershell'
              $directory = "'$directory'"
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using relative path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = "'./posh-terminator/config/windows-powershell'"
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using cdpath' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = "'posh-terminator/config/windows-powershell'"
              Set-Location -Path $HOME
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $HOME
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }
        }

        Context 'With symlinks' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'home/.posh-terminator/config'
          }

          Context 'Using absolute path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = Join-Path -Path $repoDirectory -ChildPath 'home' `
                -AdditionalChildPath '.posh-terminator', 'config'
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using relative path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = './home/.posh-terminator/config'
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using cdpath' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = 'home/.posh-terminator/config'
              Set-Location -Path $HOME
            }

            It 'sets location to $HOME' {
              Set-CDPathLocation -Path $directory
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              Set-CDPathLocation -Path $directory
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              Set-CDPathLocation -Path $directory -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                Set-CDPathLocation -Path $directory -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              Set-CDPathLocation -Path $directory -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              Set-CDPathLocation -Path $directory -WhatIf
              (Get-Location).Path | Should -Be $HOME
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }
        }

        Context 'With leading .\' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'posh-terminator\config\windows-terminal'
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '.\posh-terminator\config\windows-terminal'
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'With leading ../' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'posh-terminator\config\windows-powershell'
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '../posh-terminator/posh-terminator/config/windows-powershell'
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'With leading ..\' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'posh-terminator\config\windows-powershell'
            [SuppressMessage('PSReviewUnusedParameter', 'directory')]
            $directory = '..\posh-terminator\posh-terminator\config\windows-powershell'
          }

          It 'sets location to $HOME' {
            Set-CDPathLocation -Path $directory
            (Get-Location).Path | Should -Be $expected.FullName
          }

          It 'echos resolved location when -PassThru: $false' {
            Mock Write-Output { } -Verifiable
            Set-CDPathLocation -Path $directory
            Assert-MockCalled Write-Output -Exactly 1 `
              -ParameterFilter { $InputObject -eq $expected }
          }

          It 'passes location object when -PassThru: $true' {
            Set-CDPathLocation -Path $directory -PassThru `
              | Should -Be $expected.FullName
          }

          It 'does not throw an error' {
            {
              Set-CDPathLocation -Path $directory -ErrorAction Stop
            } | Should -Not -Throw
          }

          It 'has succeeded exit status' {
            Set-CDPathLocation -Path $directory -ErrorAction Ignore
            $? | Should -BeTrue
          }

          # NOTE no current way to suppress WhatIf output
          # see: https://github.com/PowerShell/PowerShell/issues/9870
          It 'does not change location when -WhatIf: $true' {
            Set-CDPathLocation -Path $directory -WhatIf
            (Get-Location).Path | Should -Be $repoDirectory
          }

          # TODO add -Confirm tests
          # unclear if this is even supported

          AfterEach {
            Set-Location -Path $repoDirectory
          }
        }

        Context 'Using pipeline' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'test/fixtures/has space/bar'
          }

          Context 'Using absolute path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = Join-Path -Path $testDirectory -ChildPath 'fixtures' `
                -AdditionalChildPath 'has space', 'bar'
            }

            It 'sets location to $HOME' {
              $directory | Set-CDPathLocation
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              $directory | Set-CDPathLocation
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              $directory | Set-CDPathLocation -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                $directory | Set-CDPathLocation -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              $directory | Set-CDPathLocation -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              $directory | Set-CDPathLocation -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using relative path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = './test/fixtures/has space/bar'
            }

            It 'sets location to $HOME' {
              $directory | Set-CDPathLocation
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              $directory | Set-CDPathLocation
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              $directory | Set-CDPathLocation -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                $directory | Set-CDPathLocation -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              $directory | Set-CDPathLocation -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              $directory | Set-CDPathLocation -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using cdpath' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = 'fixtures/has space/bar'
            }

            It 'sets location to $HOME' {
              $directory | Set-CDPathLocation
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              $directory | Set-CDPathLocation
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              $directory | Set-CDPathLocation -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                $directory | Set-CDPathLocation -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              $directory | Set-CDPathLocation -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              $directory | Set-CDPathLocation -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }
        }

        Context 'Using pipeline property name' {
          BeforeEach {
            [SuppressMessage('PSReviewUnusedParameter', 'expected')]
            $expected = Get-Item 'test/fixtures/has space/bar'
          }

          Context 'Using absolute path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = New-Object -TypeName PSObject `
                -Property @{
                  Path = (Join-Path -Path $testDirectory -ChildPath 'fixtures' `
                      -AdditionalChildPath 'has space', 'bar')
                }
            }

            It 'sets location to $HOME' {
              $directory | Set-CDPathLocation
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              $directory | Set-CDPathLocation
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              $directory | Set-CDPathLocation -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                $directory | Set-CDPathLocation -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              $directory | Set-CDPathLocation -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              $directory | Set-CDPathLocation -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using relative path' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = New-Object -TypeName PSObject `
                -Property @{
                  Path = './test/fixtures/has space/bar'
                }
            }

            It 'sets location to $HOME' {
              $directory | Set-CDPathLocation
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              $directory | Set-CDPathLocation
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              $directory | Set-CDPathLocation -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                $directory | Set-CDPathLocation -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              $directory | Set-CDPathLocation -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              $directory | Set-CDPathLocation -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }

          Context 'Using cdpath' {
            BeforeEach {
              [SuppressMessage('PSReviewUnusedParameter', 'directory')]
              $directory = New-Object -TypeName PSObject `
                -Property @{
                  Path = 'fixtures/has space/bar'
                }
            }

            It 'sets location to $HOME' {
              $directory | Set-CDPathLocation
              (Get-Location).Path | Should -Be $expected.FullName
            }

            It 'echos resolved location when -PassThru: $false' {
              Mock Write-Output { } -Verifiable
              $directory | Set-CDPathLocation
              Assert-MockCalled Write-Output -Exactly 1 `
                -ParameterFilter { $InputObject -eq $expected }
            }

            It 'passes location object when -PassThru: $true' {
              $directory | Set-CDPathLocation -PassThru `
                | Should -Be $expected.FullName
            }

            It 'does not throw an error' {
              {
                $directory | Set-CDPathLocation -ErrorAction Stop
              } | Should -Not -Throw
            }

            It 'has succeeded exit status' {
              $directory | Set-CDPathLocation -ErrorAction Ignore
              $? | Should -BeTrue
            }

            # NOTE no current way to suppress WhatIf output
            # see: https://github.com/PowerShell/PowerShell/issues/9870
            It 'does not change location when -WhatIf: $true' {
              $directory | Set-CDPathLocation -WhatIf
              (Get-Location).Path | Should -Be $repoDirectory
            }

            # TODO add -Confirm tests
            # unclear if this is even supported

            AfterEach {
              Set-Location -Path $repoDirectory
            }
          }
        }
      }
    }
  }
}
